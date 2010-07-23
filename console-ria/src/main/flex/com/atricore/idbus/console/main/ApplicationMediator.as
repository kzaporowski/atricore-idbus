/*
 * Atricore Console
 *
 * Copyright 2009-2010, Atricore Inc.
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

package com.atricore.idbus.console.main
{
import com.atricore.idbus.console.lifecycle.LifecycleViewMediator;

import flash.events.Event;

import mx.events.FlexEvent;
import mx.events.MenuEvent;

import com.atricore.idbus.console.main.controller.ApplicationStartUpCommand;
import com.atricore.idbus.console.main.controller.SetupServerCommand;
import com.atricore.idbus.console.main.model.SecureContextProxy;
import com.atricore.idbus.console.main.view.setup.SetupWizardViewMediator;
import com.atricore.idbus.console.modeling.main.ModelerMediator;
import com.atricore.idbus.console.modeling.main.view.appliance.IdentityApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.sso.SimpleSSOWizardViewMediator;

import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.mediator.Mediator;
import org.springextensions.actionscript.puremvc.patterns.mediator.IocMediator;

public class ApplicationMediator extends IocMediator {
    // Canonical name of the Mediator
    public static const NAME:String = "com.atricore.idbus.console.main.ApplicationMediator";
    public static const REGISTER_HEAD:String = "User Registration";

    private var _secureContext:SecureContextProxy;
    private var _popupManager:ConsolePopUpManager;

    public function ApplicationMediator(viewComp:AtricoreConsole) {
        super(NAME, viewComp);

        _secureContext = SecureContextProxy(facade.retrieveProxy(SecureContextProxy.NAME));
        facade.registerMediator(new ModelerMediator(viewComp.modelerView));
        _popupManager = new ConsolePopUpManager(facade, viewComp);

        // Add listeners for other components on the viewStack with delayed instantiation.
        viewComp.lifecycleView.addEventListener(FlexEvent.CREATION_COMPLETE, handleLifecycleViewCreated);
        viewComp.addEventListener(FlexEvent.SHOW, handleShowConsole);
    }

    public function handleLifecycleViewCreated(event:Event):void {
        facade.registerMediator(new LifecycleViewMediator(app.lifecycleView));
    }

    public function handleShowConsole(event:Event):void {

    }

    override public function listNotificationInterests():Array {
        return [ApplicationFacade.NOTE_SHOW_ERROR_MSG,
            ApplicationFacade.NOTE_SHOW_SUCCESS_MSG,
            ApplicationStartUpCommand.SUCCESS,
            ApplicationStartUpCommand.FAILURE,
            SetupServerCommand.SUCCESS,
            SetupServerCommand.FAILURE,
            SetupWizardViewMediator.RUN,
            SimpleSSOWizardViewMediator.RUN,
            IdentityApplianceMediator.CREATE,
            ApplicationFacade.NOTE_DISPLAY_APPLIANCE_MODELER
        ];
    }

    override public function handleNotification(notification:INotification):void {
        switch (notification.getName()) {
            case ApplicationStartUpCommand.SUCCESS:
                //TODO: Show login box
                break;
            case ApplicationStartUpCommand.FAILURE:
                //TODO: popupManager.showSetupWizardWindow(notification);
                break;
            case SimpleSSOWizardViewMediator.RUN:
                _popupManager.showSimpleSSOWizardWindow(notification);
                break;
            case IdentityApplianceMediator.CREATE:
                _popupManager.showCreateIdentityApplianceWindow(notification);
                break;
            case SetupServerCommand.SUCCESS:
                break;
            case SetupServerCommand.FAILURE:
                break;
            case ApplicationFacade.NOTE_SHOW_ERROR_MSG :
                app.messageBox.showFailureMessage(notification.getBody() as String);
                break;
            case ApplicationFacade.NOTE_SHOW_SUCCESS_MSG :
                app.messageBox.showSuccessMessage(notification.getBody() as String);
                break;
            case ApplicationFacade.NOTE_DISPLAY_APPLIANCE_MODELER:
                app.modelerView.setVisible(true);
                break;
        }
    }

    // TODO: remove
    private function handleMenuItemClick(event:MenuEvent):void {

        if (event.index == 1) {
            sendNotification(IdentityApplianceMediator.CREATE);
        } else
        if (event.index == 3) {
            sendNotification(SimpleSSOWizardViewMediator.RUN)
        }

    }

    public function get app():AtricoreConsole {
        return viewComponent as AtricoreConsole;
    }

}
}