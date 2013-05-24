/*
 * Atricore IDBus
 *
 * Copyright (c) 2009-2012, Atricore Inc.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

package org.atricore.idbus.capabilities.idconfirmation.component.builtin

import org.atricore.idbus.capabilities.sso.dsl.util.Logging
import org.atricore.idbus.capabilities.sso.dsl.core._
import org.atricore.idbus.capabilities.sso.dsl.core.directives.{IdentityRoute, BasicIdentityFlowDirectives}
import org.atricore.idbus.kernel.main.mediation.camel.component.binding.CamelMediationMessage
import org.atricore.idbus.capabilities.sso.dsl.core.{Reject, Pass}
import org.atricore.idbus.kernel.main.mediation.confirmation.{IdentityConfirmationTokenAuthenticationRequest, IdentityConfirmationRequest}
import scala.collection.JavaConversions._
import org.atricore.idbus.capabilities.idconfirmation.component.builtin.Rejections._
import java.security.SecureRandom
import scala.Some
import org.atricore.idbus.capabilities.sso.dsl.{RedirectToLocation,IdentityFlowResponse}
import java.net.URL
import org.atricore.idbus.kernel.main.federation.metadata.{EndpointDescriptorImpl, EndpointDescriptor}
import org.atricore.idbus.capabilities.sso.support.binding.SSOBinding

/**
 * Identity confirmation directives of the identity combinator library.
 *
 * @author <a href="mailto:gbrigandi@atricore.org">Gianluca Brigandi</a>
 */
trait BasicIdentityConfirmationDirectives extends Logging {
  this: BasicIdentityFlowDirectives =>

  def onConfirmationRequest =
    filter1[IdentityConfirmationRequest] {
      ctx =>
        log.debug("Identity Confirmation Message = " + ctx.request.exchange.getIn.asInstanceOf[CamelMediationMessage].getMessage.getContent)
        Option(ctx.request.exchange.getIn.asInstanceOf[CamelMediationMessage].getMessage.getContent) match {
          case Some(idConfReq: IdentityConfirmationRequest) =>
            Pass(idConfReq)
          case _ =>
            Reject(NoIdentityConfirmationRequestAvailable)
        }
    }

  def onConfirmationTokenAuthenticationRequest =
    filter1[IdentityConfirmationTokenAuthenticationRequest] {
      ctx =>
        Option(ctx.request.exchange.getIn.asInstanceOf[CamelMediationMessage].getMessage.getContent) match {
          case Some(idConfTokenReq: IdentityConfirmationTokenAuthenticationRequest) =>
            Pass(idConfTokenReq)
          case _ =>
            Reject(NoIdentityConfirmationTokenAuthenticationRequestAvailable)
        }
    }

  def userClaim(claimId: String) =
    filter1 {
      ctx =>
        onConfirmationRequest.filter(ctx) match {
          case Pass(values, transform) =>
            values._1.getUserClaims.find(_.getName == claimId) match {
              case Some(claimValue) =>
                Pass(claimValue)
              case None =>
                Reject(NoClaimFound)
            }
          case reject: Reject =>
            reject
        }

    }

  def identityToConfirm =
    filter1 {
      ctx =>
        userClaim("principal").filter(ctx) match {
          case Pass(values, transform) => Pass(values._1)
          case reject: Reject => reject
        }
    }

  def sourceIpAddress =
    filter1 {
      ctx =>
        userClaim("sourceIpAddress").filter(ctx) match {
          case Pass(values, transform) => Pass(values._1)
          case reject => reject
        }
    }

  def lastSourceIpAddress =
    filter1 {
      ctx =>
        userClaim("lastSourceIpAddress").filter(ctx) match {
          case Pass(values, transform) => Pass(values._1)
          case reject => reject
        }
    }

  def emailAddress =
    filter1 {
      ctx =>
        userClaim("emailAddress").filter(ctx) match {
          case Pass(values, transform) => Pass(values._1)
          case reject => reject
        }

    }

  def fromUnknownIpAddress =
    filter {
      ctx =>
        lastSourceIpAddress.filter(ctx).flatMap(lastSourceIpAddress =>
          sourceIpAddress.filter(ctx).flatMap(sourceIpAddress =>
            if (lastSourceIpAddress._1 != sourceIpAddress._1)
              Pass
            else
              Reject(IdentityConfirmationNotRequired)
          )
        )
    }

  def issueSecret(size: Int = 10) = {
    /**
     * Create a random string of a given size
     * @param size size of the string to create. Must be a positive or nul integer
     * @return the generated string
     */
    def randomString(size: Int): String = {
      val random = new SecureRandom()

      def addChar(pos: Int, lastRand: Int, sb: StringBuilder): StringBuilder = {
        if (pos >= size) sb
        else {
          val randNum = if ((pos % 6) == 0) random.nextInt else lastRand
          sb.append((randNum & 0x1f) match {
            case n if n < 26 => ('A' + n).toChar
            case n => ('0' + (n - 26)).toChar
          })
          addChar(pos + 1, randNum >> 5, sb)
        }
      }
      addChar(0, 0, new StringBuilder(size)).toString
    }

    filter1 {
      ctx =>
        Pass(randomString(size))
    }
  }

  def shareSecretByEmail(secret : String) = {
    filter {
      ctx =>
        issueSecret(10).filter(ctx).flatMap(secret =>
          emailAddress.filter(ctx).flatMap(emailAddress => {
            // TODO: send email
            log.debug("Sending secret [" + secret + "] to email address [" + emailAddress + "]")
            Pass
          }
          )
        )
    }
  }

  def notifyTokenShared(tokenSharedConfirmationUILocation : String, secret : String) : IdentityFlowRoute = {
      ctx =>
        val tsc = TokenSharedConfirmation(secret)

        ctx.respond(
          IdentityFlowResponse(
            RedirectToLocation(tokenSharedConfirmationUILocation),
            Option(tsc),
            Option("TokenSharedConfirmation"))
        )
  }

  def withIdentityConfirmationState = {
    filter1 {
      ctx =>
        val in = ctx.request.exchange.getIn.asInstanceOf[CamelMediationMessage]
        try {
          Option(in.getMessage.getState.getLocalVariable("urn:org:atricore:idbus:idconf-state").asInstanceOf[IdentityConfirmationState]) match {
            case Some(state) => Pass(state)
            case _ =>
              val state = IdentityConfirmationState(None)
              val in = ctx.request.exchange.getIn.asInstanceOf[CamelMediationMessage]
              in.getMessage.getState.setLocalVariable("urn:org:atricore:idbus:idconf-state", state)
              Pass(state)
          }
        } catch {
          case e: IllegalStateException => {
            Pass(IdentityConfirmationState(None))
          }
        }
    }
  }

  def forReceivedSecret = {
    filter1[String] {
      ctx =>
        onConfirmationTokenAuthenticationRequest.filter(ctx) match {
          case Pass(values, transform) =>
            Option(values._1.getToken) match {
              case Some(token) =>
                Pass(token)
              case None =>
                Reject(NoTokenInAuthenticationRequest)
            }
          case reject =>
            Reject(NoTokenInAuthenticationRequest)
        }
    }
  }

  def forIssuedSecret = {
    filter1[String] {
      ctx =>
        withIdentityConfirmationState.filter(ctx) match {
          case Pass(values, transform) =>
            values._1 match {
              case IdentityConfirmationState(Some(issuedSecret)) =>
                Pass(issuedSecret)
              case IdentityConfirmationState(None) =>
                Reject(NoIssuedSecretFound)
            }
          case reject =>
            Reject(NoIssuedSecretFound)
        }
    }
  }

  def verifyToken(receivedToken : String, issuedToken : String) = {
    filter {
      ctx =>
        if (receivedToken == issuedToken) Pass else Reject(AuthenticationFailed)
    }
  }

  def notifyCompletion : IdentityFlowRoute = {
    ctx =>
     //ctx.respond(IdentityFlowResponse(RedirectToUrl(new URL("http://localhost/"))))
  }


}
