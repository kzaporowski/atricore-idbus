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

package com.atricore.idbus.console.modeling.main {
import com.atricore.idbus.console.main.ApplicationFacade;
import com.atricore.idbus.console.main.model.ProjectProxy;
import com.atricore.idbus.console.main.view.progress.ProcessingMediator;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveIdentityApplianceElementRequest;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveIdentityProviderElementRequest;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveIdentityVaultElementRequest;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveIdpChannelElementRequest;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveServiceProviderElementRequest;
import com.atricore.idbus.console.modeling.diagram.model.request.RemoveSpChannelElementRequest;
import com.atricore.idbus.console.modeling.main.controller.IdentityApplianceListLoadCommand;
import com.atricore.idbus.console.modeling.main.controller.IdentityApplianceUpdateCommand;
import com.atricore.idbus.console.modeling.main.controller.LookupIdentityApplianceByIdCommand;
import com.atricore.idbus.console.modeling.main.view.*;
import com.atricore.idbus.console.modeling.main.view.appliance.IdentityApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.build.BuildApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.deploy.DeployApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.sso.SimpleSSOWizardViewMediator;
import com.atricore.idbus.console.services.dto.IdentityApplianceDTO;
import com.atricore.idbus.console.services.dto.IdentityApplianceStateDTO;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.events.FlexEvent;

import org.puremvc.as3.interfaces.INotification;
import org.springextensions.actionscript.puremvc.patterns.mediator.IocMediator;

public class ModelerMediator extends IocMediator {

    public static const viewName:String = "ModelerView";
    
    public static const BUNDLE:String = "console";

    public static const ORIENTATION_MENU_ITEM_INDEX:int = 3;

    private var _projectProxy:ProjectProxy;

    private var _identityAppliance:IdentityApplianceDTO;

    private var _emptyNotationModel:XML;

    private var _popupManager:ModelerPopUpManager;

    [Bindable]
    public var _applianceList:Array;


    public function ModelerMediator(p_mediatorName:String = null, p_viewComponent:Object = null) {
        super(p_mediatorName, p_viewComponent);
    }

    public function get projectProxy():ProjectProxy {
        return _projectProxy;
    }


    public function set projectProxy(value:ProjectProxy):void {
        _projectProxy = value;
    }


    public function get popupManager():ModelerPopUpManager {
        return _popupManager;
    }

    public function set popupManager(value:ModelerPopUpManager):void {
        _popupManager = value;
    }

    override public function setViewComponent(p_viewComponent:Object):void {
        if (getViewComponent() != null) {
            view.btnNew.removeEventListener(MouseEvent.CLICK, handleNewClick);
            view.btnOpen.removeEventListener(MouseEvent.CLICK, handleOpenClick);
            view.btnSave.removeEventListener(MouseEvent.CLICK, handleSaveClick);
            view.btnLifecycle.removeEventListener(MouseEvent.CLICK, handleLifecycleClick);
        }

        (p_viewComponent as ModelerView).addEventListener(FlexEvent.CREATION_COMPLETE, init);

        super.setViewComponent(p_viewComponent);

        init(null);  //remove this after adding login box?
    }

    public function init(event:Event):void {

        projectProxy.currentView = viewName;

        sendNotification(ApplicationFacade.CLEAR_MSG);

        if (projectProxy.currentIdentityAppliance != null) {
            sendNotification(ApplicationFacade.UPDATE_IDENTITY_APPLIANCE);
            enableIdentityApplianceActionButtons();
        } else {
            view.btnLifecycle.enabled = false;
        }

        view.btnNew.addEventListener(MouseEvent.CLICK, handleNewClick);
        view.btnOpen.addEventListener(MouseEvent.CLICK, handleOpenClick);
        view.btnSave.addEventListener(MouseEvent.CLICK, handleSaveClick);
        view.btnLifecycle.addEventListener(MouseEvent.CLICK, handleLifecycleClick);
        
        view.appliances.labelFunction = applianceListLabelFunc;
        view.btnSave.enabled = false;

        popupManager.init(iocFacade, view);

        sendNotification(ApplicationFacade.IDENTITY_APPLIANCE_LIST_LOAD);
    }


    private function handleNewClick(event:MouseEvent):void {
        trace("New Button Click: " + event);
        if (view.applianceStyle.selectedItem.data == "Advanced") {
            sendNotification(IdentityApplianceMediator.CREATE);
        } else if (view.applianceStyle.selectedItem.data == "SimpleSSO") {
            sendNotification(SimpleSSOWizardViewMediator.RUN);
        }
    }

    private function handleOpenClick(event:MouseEvent):void {
        trace("Open Button Click: " + event);
        if (view.appliances.selectedItem != null) {
            var applianceId:String = (view.appliances.selectedItem as IdentityApplianceDTO).id.toString();
            sendNotification(ProcessingMediator.START, "Opening identity appliance...");
            sendNotification(ApplicationFacade.LOOKUP_IDENTITY_APPLIANCE_BY_ID, applianceId);
        }
    }

    private function handleSaveClick(event:MouseEvent):void {
        trace("Save Button Click: " + event);
        sendNotification(ProcessingMediator.START);
        sendNotification(ApplicationFacade.IDENTITY_APPLIANCE_UPDATE);
    }

    private function handleLifecycleClick(event:MouseEvent):void {
        trace("Lifecycle Button Click: " + event);
        if (view.btnSave.enabled) {
            sendNotification(ApplicationFacade.SHOW_ERROR_MSG, "Identity appliance not saved!");
        } else {
            sendNotification(ApplicationFacade.DISPLAY_APPLIANCE_LIFECYCLE);
        }
    }
    
    override public function listNotificationInterests():Array {
        return [ApplicationFacade.UPDATE_IDENTITY_APPLIANCE,
            ApplicationFacade.REMOVE_IDENTITY_APPLIANCE_ELEMENT,
            ApplicationFacade.CREATE_IDENTITY_PROVIDER_ELEMENT,
            ApplicationFacade.REMOVE_IDENTITY_PROVIDER_ELEMENT,
            ApplicationFacade.CREATE_SERVICE_PROVIDER_ELEMENT,
            ApplicationFacade.REMOVE_SERVICE_PROVIDER_ELEMENT,
            ApplicationFacade.CREATE_IDP_CHANNEL_ELEMENT,
            ApplicationFacade.REMOVE_IDP_CHANNEL_ELEMENT,
            ApplicationFacade.CREATE_SP_CHANNEL_ELEMENT,
            ApplicationFacade.REMOVE_SP_CHANNEL_ELEMENT,
            ApplicationFacade.CREATE_DB_IDENTITY_VAULT_ELEMENT,
            ApplicationFacade.REMOVE_DB_IDENTITY_VAULT_ELEMENT,
            ApplicationFacade.MANAGE_CERTIFICATE,
            ApplicationFacade.SHOW_UPLOAD_PROGRESS,
            ApplicationFacade.IDENTITY_APPLIANCE_CHANGED,
            BuildApplianceMediator.RUN,
            DeployApplianceMediator.RUN,
            LookupIdentityApplianceByIdCommand.SUCCESS,
            LookupIdentityApplianceByIdCommand.FAILURE,
            IdentityApplianceListLoadCommand.SUCCESS,
            IdentityApplianceListLoadCommand.FAILURE,
            IdentityApplianceUpdateCommand.SUCCESS,
            IdentityApplianceUpdateCommand.FAILURE];
    }

    override public function handleNotification(notification:INotification):void {
        switch (notification.getName()) {
            case ApplicationFacade.UPDATE_IDENTITY_APPLIANCE:
                updateIdentityAppliance();
                enableIdentityApplianceActionButtons();
                break;
            case ApplicationFacade.REMOVE_IDENTITY_APPLIANCE_ELEMENT:
                var ria:RemoveIdentityApplianceElementRequest = RemoveIdentityApplianceElementRequest(notification.getBody());
                // TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.IDENTITY_APPLIANCE_REMOVE, ria.identityAppliance);
                break;
            case ApplicationFacade.CREATE_IDENTITY_PROVIDER_ELEMENT:
                popupManager.showCreateIdentityProviderWindow(notification);
                break;
            case ApplicationFacade.REMOVE_IDENTITY_PROVIDER_ELEMENT:
                var rip:RemoveIdentityProviderElementRequest = RemoveIdentityProviderElementRequest(notification.getBody());
                // TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.IDENTITY_PROVIDER_REMOVE, rip.identityProvider);
                break;
            case ApplicationFacade.CREATE_SERVICE_PROVIDER_ELEMENT:
                popupManager.showCreateServiceProviderWindow(notification);
                break;
            case ApplicationFacade.REMOVE_SERVICE_PROVIDER_ELEMENT:
                var rsp:RemoveServiceProviderElementRequest = RemoveServiceProviderElementRequest(notification.getBody());
                //                 TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.SERVICE_PROVIDER_REMOVE, rsp.serviceProvider);
                break;
            case ApplicationFacade.CREATE_IDP_CHANNEL_ELEMENT:
                popupManager.showCreateIdpChannelWindow(notification);
                break;
            case ApplicationFacade.REMOVE_IDP_CHANNEL_ELEMENT:
                var ridpc:RemoveIdpChannelElementRequest = RemoveIdpChannelElementRequest(notification.getBody());
                //                 TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.IDP_CHANNEL_REMOVE, ridpc.idpChannel);
                break;
            case ApplicationFacade.CREATE_SP_CHANNEL_ELEMENT:
                popupManager.showCreateSpChannelWindow(notification);
                break;
            case ApplicationFacade.REMOVE_SP_CHANNEL_ELEMENT:
                var rspc:RemoveSpChannelElementRequest = RemoveSpChannelElementRequest(notification.getBody());
                //                 TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.SP_CHANNEL_REMOVE, rspc.spChannel);
                break;

            case ApplicationFacade.CREATE_DB_IDENTITY_VAULT_ELEMENT:
                popupManager.showCreateDbIdentityVaultWindow(notification);
                break;
            case ApplicationFacade.REMOVE_DB_IDENTITY_VAULT_ELEMENT:
                var rdbiv:RemoveIdentityVaultElementRequest = RemoveIdentityVaultElementRequest(notification.getBody());
                //                 TODO: Perform UI handling for confirming removal action
                sendNotification(ApplicationFacade.DB_IDENTITY_VAULT_REMOVE, rdbiv.identityVault);
                break;
            case ApplicationFacade.MANAGE_CERTIFICATE:
                popupManager.showManageCertificateWindow(notification);
                break;
            case ApplicationFacade.SHOW_UPLOAD_PROGRESS:
                popupManager.showUploadProgressWindow(notification);
                break;
            case ApplicationFacade.IDENTITY_APPLIANCE_CHANGED:
                if (projectProxy.currentIdentityAppliance.state == IdentityApplianceStateDTO.PROJECTED.name) {
                    view.btnSave.enabled = true;
                }
                break;
            case BuildApplianceMediator.RUN:
                popupManager.showBuildIdentityApplianceWindow(notification);
                break;
            case DeployApplianceMediator.RUN:
                popupManager.showDeployIdentityApplianceWindow(notification);
                break;
            case LookupIdentityApplianceByIdCommand.SUCCESS:
                view.btnSave.enabled = false;
                view.btnLifecycle.enabled = false;
                enableIdentityApplianceActionButtons();
                sendNotification(ProcessingMediator.STOP);
                sendNotification(ApplicationFacade.DISPLAY_APPLIANCE_MODELER);
                sendNotification(ApplicationFacade.UPDATE_IDENTITY_APPLIANCE);
                sendNotification(ApplicationFacade.SHOW_SUCCESS_MSG,
                        "Appliance successfully opened.");
                break;
            case LookupIdentityApplianceByIdCommand.FAILURE:
                sendNotification(ProcessingMediator.STOP);
                sendNotification(ApplicationFacade.SHOW_ERROR_MSG,
                        "There was an error opening appliance.");
                break;
            case IdentityApplianceListLoadCommand.SUCCESS:
                view.appliances.dataProvider = projectProxy.identityApplianceList;
                break;
            case IdentityApplianceListLoadCommand.FAILURE:
                sendNotification(ApplicationFacade.SHOW_ERROR_MSG,
                        "There was an error retrieving list of appliances.");
                break;
            case IdentityApplianceUpdateCommand.SUCCESS:
                view.btnSave.enabled = false;
                sendNotification(ProcessingMediator.STOP);
                sendNotification(ApplicationFacade.DISPLAY_APPLIANCE_MODELER);
                sendNotification(ApplicationFacade.UPDATE_IDENTITY_APPLIANCE);
                sendNotification(ApplicationFacade.SHOW_SUCCESS_MSG,
                        "Appliance successfully updated.");
                break;
            case IdentityApplianceUpdateCommand.FAILURE:
                sendNotification(ProcessingMediator.STOP);
                sendNotification(ApplicationFacade.SHOW_ERROR_MSG,
                        "There was an error updating appliance.");
                break;
        }

    }

    private function updateIdentityAppliance():void {
        _identityAppliance = projectProxy.currentIdentityAppliance;
        sendNotification(ApplicationFacade.IDENTITY_APPLIANCE_LIST_LOAD);
    }

    private function enableIdentityApplianceActionButtons():void {
        var appliance:IdentityApplianceDTO = projectProxy.currentIdentityAppliance;
        if (appliance != null && appliance.idApplianceDeployment == null) {
            view.btnLifecycle.enabled = true;
        }
    }

    private function applianceListLabelFunc(item:Object):String {
        return (item as IdentityApplianceDTO).idApplianceDefinition.name;
    }

    protected function get view():ModelerView
    {
        return viewComponent as ModelerView;
    }

}
}