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

package com.atricore.idbus.console.modeling.main.view {
import com.atricore.idbus.console.main.BasePopUpManager;
import com.atricore.idbus.console.main.view.certificate.ManageCertificateMediator;
import com.atricore.idbus.console.main.view.certificate.ManageCertificateView;
import com.atricore.idbus.console.main.view.upload.UploadProgress;
import com.atricore.idbus.console.main.view.upload.UploadProgressMediator;
import com.atricore.idbus.console.modeling.diagram.view.dbidentityvault.DbIdentityVaultWizardView;
import com.atricore.idbus.console.modeling.diagram.view.dbidentityvault.DbIdentityVaultWizardViewMediator;
import com.atricore.idbus.console.modeling.diagram.view.idp.IdentityProviderCreateForm;
import com.atricore.idbus.console.modeling.diagram.view.idp.IdentityProviderCreateMediator;
import com.atricore.idbus.console.modeling.diagram.view.idpchannel.IDPChannelCreateForm;
import com.atricore.idbus.console.modeling.diagram.view.idpchannel.IDPChannelCreateMediator;
import com.atricore.idbus.console.modeling.diagram.view.sp.ServiceProviderCreateForm;
import com.atricore.idbus.console.modeling.diagram.view.sp.ServiceProviderCreateMediator;
import com.atricore.idbus.console.modeling.diagram.view.spchannel.SPChannelCreateForm;
import com.atricore.idbus.console.modeling.diagram.view.spchannel.SPChannelCreateMediator;
import com.atricore.idbus.console.modeling.main.ModelerView;
import com.atricore.idbus.console.modeling.main.view.build.BuildApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.build.BuildApplianceView;
import com.atricore.idbus.console.modeling.main.view.deploy.DeployApplianceMediator;
import com.atricore.idbus.console.modeling.main.view.deploy.DeployApplianceView;

import mx.events.FlexEvent;

import org.puremvc.as3.interfaces.INotification;
import org.springextensions.actionscript.puremvc.interfaces.IIocFacade;

public class ModelerPopUpManager extends BasePopUpManager {

    // mediators
    private var _manageCertificateMediator:ManageCertificateMediator;
    private var _identityProviderMediator:IdentityProviderCreateMediator;
    private var _serviceProviderMediator:ServiceProviderCreateMediator;
    private var _idpChannelCreateMediator:IDPChannelCreateMediator;
    private var _spChannelCreateMediator:SPChannelCreateMediator;
    private var _dbIdentityVaultWizardViewMediator:DbIdentityVaultWizardViewMediator;
    private var _uploadProgressMediator:UploadProgressMediator;
    private var _buildApplianceMediator:BuildApplianceMediator;
    private var _deployApplianceMediator:DeployApplianceMediator;

    // views
    private var _identityProviderCreateForm:IdentityProviderCreateForm;
    private var _serviceProviderCreateForm:ServiceProviderCreateForm;
    private var _idpChannelCreateForm:IDPChannelCreateForm;
    private var _spChannelCreateForm:SPChannelCreateForm;
    private var _dbIdentityVaultWizardView:DbIdentityVaultWizardView;
    private var _manageCertificateForm:ManageCertificateView;
    private var _uploadProgress:UploadProgress;
    private var _buildAppliance:BuildApplianceView;
    private var _deployAppliance:DeployApplianceView;

    public function ModelerPopUpManager(facade:IIocFacade, modeler:ModelerView) {
        super(facade, modeler);
        _popup.styleName = "modelerPopup";
    }
    
    public function set manageCertificateMediator(value:ManageCertificateMediator) {
        _manageCertificateMediator = value;
    }

    public function get manageCertificateMediator():ManageCertificateMediator {
        return _manageCertificateMediator;
    }

    public function get identityProviderMediator():IdentityProviderCreateMediator {
        return _identityProviderMediator;
    }

    public function set identityProviderMediator(value:IdentityProviderCreateMediator):void {
        _identityProviderMediator = value;
    }

    public function get serviceProviderMediator():ServiceProviderCreateMediator {
        return _serviceProviderMediator;
    }

    public function set serviceProviderMediator(value:ServiceProviderCreateMediator):void {
        _serviceProviderMediator = value;
    }

    public function get idpChannelCreateMediator():IDPChannelCreateMediator {
        return _idpChannelCreateMediator;
    }

    public function set idpChannelCreateMediator(value:IDPChannelCreateMediator):void {
        _idpChannelCreateMediator = value;
    }

    public function get spChannelCreateMediator():SPChannelCreateMediator {
        return _spChannelCreateMediator;
    }

    public function set spChannelCreateMediator(value:SPChannelCreateMediator):void {
        _spChannelCreateMediator = value;
    }

    public function get dbIdentityVaultWizardViewMediator():DbIdentityVaultWizardViewMediator {
        return _dbIdentityVaultWizardViewMediator;
    }

    public function set dbIdentityVaultWizardViewMediator(value:DbIdentityVaultWizardViewMediator):void {
        _dbIdentityVaultWizardViewMediator = value;
    }

    public function get uploadProgressMediator():UploadProgressMediator {
        return _uploadProgressMediator;
    }

    public function set uploadProgressMediator(value:UploadProgressMediator):void {
        _uploadProgressMediator = value;
    }

    public function get buildApplianceMediator():BuildApplianceMediator {
        return _buildApplianceMediator;
    }

    public function set buildApplianceMediator(value:BuildApplianceMediator):void {
        _buildApplianceMediator = value;
    }

    public function get deployApplianceMediator():DeployApplianceMediator {
        return _deployApplianceMediator;
    }

    public function set deployApplianceMediator(value:DeployApplianceMediator):void {
        _deployApplianceMediator = value;
    }

    public function showCreateIdentityProviderWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        if (!_identityProviderCreateForm) {
           createIdentityProviderCreateForm();
        }
        _popup.title = "Create Identity Provider";
        _popup.width = 690;
        _popup.height = 510;
        _popup.x = (_popupParent.width / 2) - 225;
        _popup.y = 80;
        showPopup(_identityProviderCreateForm);
    }

    private function createIdentityProviderCreateForm():void {
        _identityProviderCreateForm = new IdentityProviderCreateForm();
        _identityProviderCreateForm.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdentityProviderCreateFormCreated);
    }

    private function handleIdentityProviderCreateFormCreated(event:FlexEvent):void {
        identityProviderMediator.setViewComponent(_identityProviderCreateForm);
        identityProviderMediator.handleNotification(_lastWindowNotification);
    }

    public function showCreateServiceProviderWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        if (!_serviceProviderCreateForm) {
           createServiceProviderCreateForm();
        }
        _popup.title = "Create Service Provider";
        _popup.width = 690;
        _popup.height = 550;
        _popup.x = (_popupParent.width / 2) - 225;
        _popup.y = 80;
        showPopup(_serviceProviderCreateForm);
    }

    private function createServiceProviderCreateForm():void {
        _serviceProviderCreateForm = new ServiceProviderCreateForm();
        _serviceProviderCreateForm.addEventListener(FlexEvent.CREATION_COMPLETE, handleServiceProviderCreateFormCreated);
    }

    private function handleServiceProviderCreateFormCreated(event:FlexEvent):void {
        serviceProviderMediator.setViewComponent(_serviceProviderCreateForm);
        serviceProviderMediator.handleNotification(_lastWindowNotification);
    }

    public function showCreateIdpChannelWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        if (!_idpChannelCreateForm) {
           createIdpChannelCreateForm();
        }
        _popup.title = "Create Identity Provider Channel";
        _popup.width = 690;
        _popup.height = 550;
        _popup.x = (_popupParent.width / 2) - 225;
        _popup.y = 80;
        showPopup(_idpChannelCreateForm);
    }

    private function createIdpChannelCreateForm():void {
        _idpChannelCreateForm = new IDPChannelCreateForm();
        _idpChannelCreateForm.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdpChannelCreateFormCreated);
    }

    private function handleIdpChannelCreateFormCreated(event:FlexEvent):void {
        idpChannelCreateMediator.setViewComponent(_idpChannelCreateForm);
        idpChannelCreateMediator.handleNotification(_lastWindowNotification);
    }

    public function showCreateSpChannelWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        if (!_spChannelCreateForm) {
           createSpChannelCreateForm();
        }
        _popup.title = "Create Service Provider Channel";
        _popup.width = 690;
        _popup.height = 510;
        _popup.x = (_popupParent.width / 2) - 225;
        _popup.y = 80;
        showPopup(_spChannelCreateForm);
    }

    private function createSpChannelCreateForm():void {
        _spChannelCreateForm = new SPChannelCreateForm();
        _spChannelCreateForm.addEventListener(FlexEvent.CREATION_COMPLETE, handleSpChannelCreateFormCreated);
    }

    private function handleSpChannelCreateFormCreated(event:FlexEvent):void {
        spChannelCreateMediator.setViewComponent(_spChannelCreateForm);
        spChannelCreateMediator.handleNotification(_lastWindowNotification);
    }

    public function showCreateDbIdentityVaultWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        createDbIdentityVaultWizardView();
        showWizard(_dbIdentityVaultWizardView);
    }

    private function createDbIdentityVaultWizardView():void {
        _dbIdentityVaultWizardView = new DbIdentityVaultWizardView();
        _dbIdentityVaultWizardView.addEventListener(FlexEvent.CREATION_COMPLETE, handleDbIdentityVaultWizardViewCreated);
    }

    private function handleDbIdentityVaultWizardViewCreated(event:FlexEvent):void {
        dbIdentityVaultWizardViewMediator.setViewComponent(_dbIdentityVaultWizardView);
        dbIdentityVaultWizardViewMediator.handleNotification(_lastWindowNotification);
    }

    public function showManageCertificateWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        createManageCertificateForm();
        _popup.title = "Manage Certificate";
        _popup.width = 400;
        _popup.height = 480;
        showPopup(_manageCertificateForm);
    }
    
    private function createManageCertificateForm():void {
        _manageCertificateForm = new ManageCertificateView();
        _manageCertificateForm.addEventListener(FlexEvent.CREATION_COMPLETE, handleManageCertificateFormCreated);
    }

    private function handleManageCertificateFormCreated(event:FlexEvent):void {
        manageCertificateMediator.setViewComponent(_manageCertificateForm);
        manageCertificateMediator.handleNotification(_lastWindowNotification);
    }

    public function showUploadProgressWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        createUploadProgressWindow();
        _progress.title = "File upload";
        _progress.width = 300;
        _progress.height = 170;
        //_progress.x = (_popupParent.width / 2) - 225;
        //_progress.y = 80;
        showProgress(_uploadProgress);
    }

    private function createUploadProgressWindow():void {
        _uploadProgress = new UploadProgress();
        _uploadProgress.addEventListener(FlexEvent.CREATION_COMPLETE, handleUploadProgressWindowCreated);
    }

    private function handleUploadProgressWindowCreated(event:FlexEvent):void {
        uploadProgressMediator.setViewComponent(_uploadProgress);
        uploadProgressMediator.handleNotification(_lastWindowNotification);
    }

    public function showBuildIdentityApplianceWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        createBuildApplianceWindow();
        _popup.title = "Build Identity Appliance";
        _popup.width = 430;
        _popup.height = 230;
        //_progress.x = (_popupParent.width / 2) - 225;
        //_progress.y = 80;
        showPopup(_buildAppliance);
    }

    private function createBuildApplianceWindow():void {
        _buildAppliance = new BuildApplianceView();
        _buildAppliance.addEventListener(FlexEvent.CREATION_COMPLETE, handleBuildApplianceWindowCreated);
    }

    private function handleBuildApplianceWindowCreated(event:FlexEvent):void {
        buildApplianceMediator.setViewComponent(_buildAppliance);
        buildApplianceMediator.handleNotification(_lastWindowNotification);
    }

    public function showDeployIdentityApplianceWindow(notification:INotification):void {
        _lastWindowNotification = notification;
        createDeployApplianceWindow();
        _popup.title = "Deploy Identity Appliance";
        _popup.width = 430;
        _popup.height = 230;
        //_progress.x = (_popupParent.width / 2) - 225;
        //_progress.y = 80;
        showPopup(_deployAppliance);
    }

    private function createDeployApplianceWindow():void {
        _deployAppliance = new DeployApplianceView();
        _deployAppliance.addEventListener(FlexEvent.CREATION_COMPLETE, handleDeployApplianceWindowCreated);
    }

    private function handleDeployApplianceWindowCreated(event:FlexEvent):void {
        deployApplianceMediator.setViewComponent(_deployAppliance);
        deployApplianceMediator.handleNotification(_lastWindowNotification);
    }

}
}