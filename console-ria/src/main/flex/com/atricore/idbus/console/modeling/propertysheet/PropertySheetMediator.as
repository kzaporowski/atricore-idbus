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

package com.atricore.idbus.console.modeling.propertysheet {
import com.atricore.idbus.console.modeling.propertysheet.view.idp.IdentityProviderContractSection;
import com.atricore.idbus.console.modeling.propertysheet.view.idpchannel.IDPChannelContractSection;
import com.atricore.idbus.console.modeling.propertysheet.view.idpchannel.IDPChannelCoreSection;
import com.atricore.idbus.console.modeling.propertysheet.view.sp.ServiceProviderContractSection;
import com.atricore.idbus.console.modeling.propertysheet.view.sp.ServiceProviderCoreSection;
import com.atricore.idbus.console.services.dto.BindingDTO;
import com.atricore.idbus.console.services.dto.ChannelDTO;
import com.atricore.idbus.console.services.dto.IdentityApplianceDTO;

import com.atricore.idbus.console.services.dto.IdentityProviderChannelDTO;
import com.atricore.idbus.console.services.dto.IdentityProviderDTO;

import com.atricore.idbus.console.services.dto.LocationDTO;
import com.atricore.idbus.console.services.dto.ProfileDTO;

import com.atricore.idbus.console.services.dto.ServiceProviderChannelDTO;

import com.atricore.idbus.console.services.dto.ServiceProviderDTO;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.containers.Canvas;
import mx.containers.ViewStack;
import mx.controls.TabBar;
import mx.events.FlexEvent;

import com.atricore.idbus.console.main.ApplicationFacade;
import com.atricore.idbus.console.main.model.ProjectProxy;
import com.atricore.idbus.console.modeling.propertysheet.view.appliance.IdentityApplianceCoreSection;
import com.atricore.idbus.console.modeling.propertysheet.view.idp.IdentityProviderCoreSection;

import org.puremvc.as3.interfaces.INotification;
import org.puremvc.as3.patterns.mediator.Mediator;

public class PropertySheetMediator extends Mediator {
    public static const NAME:String = "PropertySheetMediator";
    private var _tabbedPropertiesTabBar:TabBar;
    private var _propertySheetsViewStack:ViewStack;
    private var _iaCoreSection:IdentityApplianceCoreSection;
    private var _ipCoreSection:IdentityProviderCoreSection;
    private var _spCoreSection:ServiceProviderCoreSection;
    private var _idpChannelCoreSection:IDPChannelCoreSection;
    private var _projectProxy:ProjectProxy;
    private var _currentIdentityApplianceElement:Object;
    private var _ipContractSection:IdentityProviderContractSection;
    private var _spContractSection:ServiceProviderContractSection;
    private var _idpChannelContractSection:IDPChannelContractSection;

    public function PropertySheetMediator(viewComp:PropertySheetView) {
        super(NAME, viewComp);
        _tabbedPropertiesTabBar = viewComp.tabbedPropertiesTabBar
        _propertySheetsViewStack = viewComp.propertySheetsViewStack;
        _projectProxy = ProjectProxy(facade.retrieveProxy(ProjectProxy.NAME));
    }

    override public function listNotificationInterests():Array {
        return [ApplicationFacade.NOTE_DIAGRAM_ELEMENT_CREATION_COMPLETE,
            ApplicationFacade.NOTE_UPDATE_IDENTITY_APPLIANCE,
            ApplicationFacade.NOTE_DIAGRAM_ELEMENT_SELECTED];
    }

    override public function handleNotification(notification:INotification):void {
        switch (notification.getName()) {
            case ApplicationFacade.NOTE_UPDATE_IDENTITY_APPLIANCE:
                clearPropertyTabs();
                break;
            case ApplicationFacade.NOTE_DIAGRAM_ELEMENT_SELECTED:
                if (_projectProxy.currentIdentityApplianceElement is IdentityApplianceDTO) {
                    _currentIdentityApplianceElement = _projectProxy.currentIdentityApplianceElement;
                    enableIdentityAppliancePropertyTabs();
                } else
                if (_projectProxy.currentIdentityApplianceElement is IdentityProviderDTO) {
                    _currentIdentityApplianceElement = _projectProxy.currentIdentityApplianceElement;
                    enableIdentityProviderPropertyTabs();
                } else
                if(_projectProxy.currentIdentityApplianceElement is ServiceProviderDTO) {
                    _currentIdentityApplianceElement = _projectProxy.currentIdentityApplianceElement;
                    enableServiceProviderPropertyTabs();                    
                } else
                if(_projectProxy.currentIdentityApplianceElement is IdentityProviderChannelDTO) {
                    _currentIdentityApplianceElement = _projectProxy.currentIdentityApplianceElement;
                    enableIdpChannelPropertyTabs();
                }
                break;
        }

    }

    protected function enableIdentityAppliancePropertyTabs():void {
        // Attach appliance editor form to property tabbed view
        _propertySheetsViewStack.removeAllChildren();

        var corePropertyTab:Canvas = new Canvas();
        corePropertyTab.id = "propertySheetCoreSection";
        corePropertyTab.label = "Core";
        corePropertyTab.width = Number("100%");
        corePropertyTab.height = Number("100%");
        corePropertyTab.setStyle("borderStyle", "solid");

        _iaCoreSection = new IdentityApplianceCoreSection();
        corePropertyTab.addChild(_iaCoreSection);
        _propertySheetsViewStack.addChild(corePropertyTab);

        _iaCoreSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleCorePropertyTabCreationComplete);
        corePropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleIdentityApplianceCorePropertyTabRollOut);

    }

    private function handleCorePropertyTabCreationComplete(event:Event):void {
        var identityAppliance:IdentityApplianceDTO;

        // fetch appliance object
        var proxy:ProjectProxy = facade.retrieveProxy(ProjectProxy.NAME) as ProjectProxy;
        identityAppliance = proxy.currentIdentityAppliance;

        // bind view
        _iaCoreSection.applianceName.text = identityAppliance.idApplianceDefinition.name;
        _iaCoreSection.applianceDescription.text = identityAppliance.idApplianceDefinition.description;

        var location:LocationDTO = identityAppliance.idApplianceDefinition.location;
        for (var i:int = 0; i < _iaCoreSection.applianceLocationProtocol.dataProvider.length; i++) {
            if (location != null && location.protocol == _iaCoreSection.applianceLocationProtocol.dataProvider[i].label) {
                _iaCoreSection.applianceLocationProtocol.selectedIndex = i;
                break;
            }
        }
        _iaCoreSection.applianceLocationDomain.text = location.host;
        _iaCoreSection.applianceLocationPort.text = location.port.toString();
        _iaCoreSection.applianceLocationPath.text = location.context;
    }

    private function handleIdentityApplianceCorePropertyTabRollOut(e:Event):void {
        trace(e);
        // bind model
        // fetch appliance object
        var identityAppliance:IdentityApplianceDTO;
        var proxy:ProjectProxy = facade.retrieveProxy(ProjectProxy.NAME) as ProjectProxy;
        identityAppliance = proxy.currentIdentityAppliance;

        var applianceChanged:Boolean = false;
        var oldLocation:LocationDTO = identityAppliance.idApplianceDefinition.location;
        var description:String = identityAppliance.idApplianceDefinition.description;
        if (description == null) {
            description = "";
        }
        if (identityAppliance.idApplianceDefinition.name != _iaCoreSection.applianceName.text ||
                description != _iaCoreSection.applianceDescription.text ||
                oldLocation.protocol != _iaCoreSection.applianceLocationProtocol.selectedLabel ||
                oldLocation.host != _iaCoreSection.applianceLocationDomain.text ||
                oldLocation.port != parseInt(_iaCoreSection.applianceLocationPort.text) ||
                oldLocation.context != _iaCoreSection.applianceLocationPath.text) {
            applianceChanged = true;
        }

        identityAppliance.idApplianceDefinition.name = _iaCoreSection.applianceName.text;
        identityAppliance.idApplianceDefinition.description = _iaCoreSection.applianceDescription.text;
        var loc:LocationDTO = new LocationDTO();
        loc.protocol = _iaCoreSection.applianceLocationProtocol.selectedLabel;
        loc.host = _iaCoreSection.applianceLocationDomain.text;
        loc.port = parseInt(_iaCoreSection.applianceLocationPort.text);
        loc.context = _iaCoreSection.applianceLocationPath.text;
        identityAppliance.idApplianceDefinition.location = loc;

        sendNotification(ApplicationFacade.NOTE_DIAGRAM_ELEMENT_UPDATED);
        if (applianceChanged) {
            sendNotification(ApplicationFacade.NOTE_IDENTITY_APPLIANCE_CHANGED);
        }
    }

    protected function enableIdentityProviderPropertyTabs():void {
        // Attach appliance editor form to property tabbed view
        _propertySheetsViewStack.removeAllChildren();

        // Core Tab
        var corePropertyTab:Canvas = new Canvas();
        corePropertyTab.id = "propertySheetCoreSection";
        corePropertyTab.label = "Core";
        corePropertyTab.width = Number("100%");
        corePropertyTab.height = Number("100%");
        corePropertyTab.setStyle("borderStyle", "solid");

        _ipCoreSection = new IdentityProviderCoreSection();
        corePropertyTab.addChild(_ipCoreSection);
        _propertySheetsViewStack.addChild(corePropertyTab);

        _ipCoreSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdentityProviderCorePropertyTabCreationComplete);
        corePropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleIdentityProviderCorePropertyTabRollOut);

        // Contract Tab
        var contractPropertyTab:Canvas = new Canvas();
        contractPropertyTab.id = "propertySheetContractSection";
        contractPropertyTab.label = "Contract";
        contractPropertyTab.width = Number("100%");
        contractPropertyTab.height = Number("100%");
        contractPropertyTab.setStyle("borderStyle", "solid");

        _ipContractSection = new IdentityProviderContractSection();
        contractPropertyTab.addChild(_ipContractSection);
        _propertySheetsViewStack.addChild(contractPropertyTab);

        _ipContractSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdentityProviderContractPropertyTabCreationComplete);
        contractPropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleIdentityProviderContractPropertyTabRollOut);
    }

    protected function enableServiceProviderPropertyTabs():void {
        // Attach appliance editor form to property tabbed view
        _propertySheetsViewStack.removeAllChildren();

        // Core Tab
        var corePropertyTab:Canvas = new Canvas();
        corePropertyTab.id = "propertySheetCoreSection";
        corePropertyTab.label = "Core";
        corePropertyTab.width = Number("100%");
        corePropertyTab.height = Number("100%");
        corePropertyTab.setStyle("borderStyle", "solid");

        _spCoreSection = new ServiceProviderCoreSection();
        corePropertyTab.addChild(_spCoreSection);
        _propertySheetsViewStack.addChild(corePropertyTab);

        _spCoreSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleServiceProviderCorePropertyTabCreationComplete);
        corePropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleServiceProviderCorePropertyTabRollOut);

        // Contract Tab
        var contractPropertyTab:Canvas = new Canvas();
        contractPropertyTab.id = "propertySheetContractSection";
        contractPropertyTab.label = "Contract";
        contractPropertyTab.width = Number("100%");
        contractPropertyTab.height = Number("100%");
        contractPropertyTab.setStyle("borderStyle", "solid");

        _spContractSection = new ServiceProviderContractSection();
        contractPropertyTab.addChild(_spContractSection);
        _propertySheetsViewStack.addChild(contractPropertyTab);

        _spContractSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleServiceProviderContractPropertyTabCreationComplete);
        contractPropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleServiceProviderContractPropertyTabRollOut);
    }

    private function handleIdentityProviderCorePropertyTabCreationComplete(event:Event):void {
        var identityProvider:IdentityProviderDTO;

        identityProvider = _currentIdentityApplianceElement as IdentityProviderDTO;

        // bind view
        _ipCoreSection.identityProviderName.text = identityProvider.name;
        _ipCoreSection.identityProvDescription.text = identityProvider.description;
        //TODO

        for (var i:int = 0; i < _ipCoreSection.idpLocationProtocol.dataProvider.length; i++) {
            if (identityProvider.location != null && _ipCoreSection.idpLocationProtocol.dataProvider[i].label == identityProvider.location.protocol) {
                _ipCoreSection.idpLocationProtocol.selectedIndex = i;
                break;
            }
        }
        _ipCoreSection.idpLocationDomain.text = identityProvider.location.host;
        _ipCoreSection.idpLocationPort.text = identityProvider.location.port.toString();
        _ipCoreSection.idpLocationContext.text = identityProvider.location.context;
        _ipCoreSection.idpLocationPath.text = identityProvider.location.uri;
    }


    private function handleIdentityProviderCorePropertyTabRollOut(e:Event):void {
        // bind model
        var identityProvider:IdentityProviderDTO;

        identityProvider = _currentIdentityApplianceElement as IdentityProviderDTO;

        var applianceChanged:Boolean = false;
        var oldLocation:LocationDTO = identityProvider.location;
        var description:String = identityProvider.description;
        if (description == null) {
            description = "";
        }
        if (identityProvider.name != _ipCoreSection.identityProviderName.text ||
                description != _ipCoreSection.identityProvDescription.text ||
                oldLocation.protocol != _ipCoreSection.idpLocationProtocol.selectedLabel ||
                oldLocation.host != _ipCoreSection.idpLocationDomain.text ||
                oldLocation.port != parseInt(_ipCoreSection.idpLocationPort.text) ||
                oldLocation.context != _ipCoreSection.idpLocationContext.text ||
                oldLocation.uri != _ipCoreSection.idpLocationPath.text) {
            applianceChanged = true;
        }

        identityProvider.name = _ipCoreSection.identityProviderName.text;
        identityProvider.description = _ipCoreSection.identityProvDescription.text;

        var loc:LocationDTO = new LocationDTO();
        loc.protocol = _ipCoreSection.idpLocationProtocol.selectedLabel;
        loc.host = _ipCoreSection.idpLocationDomain.text;
        loc.port = parseInt(_ipCoreSection.idpLocationPort.text);
        loc.context = _ipCoreSection.idpLocationContext.text;
        loc.uri = _ipCoreSection.idpLocationPath.text;
        identityProvider.location = loc;

        // TODO save remaining fields to defaultChannel, calling appropriate lookup methods
        //userInformationLookup
        //authenticationContract
        //authenticationMechanism
        //authenticationAssertionEmissionPolicy

        sendNotification(ApplicationFacade.NOTE_DIAGRAM_ELEMENT_UPDATED);
        if (applianceChanged) {
            sendNotification(ApplicationFacade.NOTE_IDENTITY_APPLIANCE_CHANGED);
        }
    }

    private function handleIdentityProviderContractPropertyTabCreationComplete(event:Event):void {

        var identityProvider:IdentityProviderDTO;

        identityProvider = _currentIdentityApplianceElement as IdentityProviderDTO;

        _ipContractSection.signAuthAssertionCheck.selected = identityProvider.signAuthenticationAssertions;
        _ipContractSection.encryptAuthAssertionCheck.selected = identityProvider.encryptAuthenticationAssertions;

        var defaultChannel:ChannelDTO = identityProvider.defaultChannel;
        if (defaultChannel != null) {
            for (var j:int = 0; j < defaultChannel.activeBindings.length; j ++) {
                var tmpBinding:BindingDTO = defaultChannel.activeBindings.getItemAt(j) as BindingDTO;
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_POST.name) {
                    _ipContractSection.samlBindingHttpPostCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_REDIRECT.name) {
                    _ipContractSection.samlBindingHttpRedirectCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_ARTIFACT.name) {
                    _ipContractSection.samlBindingArtifactCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_SOAP.name) {
                    _ipContractSection.samlBindingSoapCheck.selected = true;
                }
            }
            for (j = 0; j < defaultChannel.activeProfiles.length; j++) {
                var tmpProfile:ProfileDTO = defaultChannel.activeProfiles.getItemAt(j) as ProfileDTO;
                if (tmpProfile.name == ProfileDTO.SSO.name) {
                    _ipContractSection.samlProfileSSOCheck.selected = true;
                }
                if (tmpProfile.name == ProfileDTO.SSO_SLO.name) {
                    _ipContractSection.samlProfileSLOCheck.selected = true;
                }
            }
        }
    }

    private function handleIdentityProviderContractPropertyTabRollOut(event:Event):void {

        var identityProvider:IdentityProviderDTO;

        identityProvider = _currentIdentityApplianceElement as IdentityProviderDTO;

        //var spChannel:ServiceProviderChannelDTO = new ServiceProviderChannelDTO();
        var spChannel:ServiceProviderChannelDTO = identityProvider.defaultChannel as ServiceProviderChannelDTO;

        var applianceChanged:Boolean = false;
        var oldActiveBindings:ArrayCollection = spChannel.activeBindings;
        var oldActiveProfiles:ArrayCollection = spChannel.activeProfiles;
        if (oldActiveBindings == null) {
            oldActiveBindings = new  ArrayCollection();
        }
        if (oldActiveProfiles == null) {
            oldActiveProfiles = new  ArrayCollection();
        }

        spChannel.activeBindings = new ArrayCollection();
        if (_ipContractSection.samlBindingHttpPostCheck.selected) {
            spChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_POST);
        }
        if (_ipContractSection.samlBindingArtifactCheck.selected) {
            spChannel.activeBindings.addItem(BindingDTO.SAMLR2_ARTIFACT);
        }
        if (_ipContractSection.samlBindingHttpRedirectCheck.selected) {
            spChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_REDIRECT);
        }
        if (_ipContractSection.samlBindingSoapCheck.selected) {
            spChannel.activeBindings.addItem(BindingDTO.SAMLR2_SOAP);
        }

        spChannel.activeProfiles = new ArrayCollection();
        if (_ipContractSection.samlProfileSSOCheck.selected) {
            spChannel.activeProfiles.addItem(ProfileDTO.SSO);
        }
        if (_ipContractSection.samlProfileSLOCheck.selected) {
            spChannel.activeProfiles.addItem(ProfileDTO.SSO_SLO);
        }

        if (spChannel.activeBindings.length != oldActiveBindings.length) {
            applianceChanged = true;
        } else {
            for (var i:int = 0; i < spChannel.activeBindings.length; i++) {
                var binding:BindingDTO = spChannel.activeBindings[i];
                var bindingFound:Boolean = false;
                for (var j:int = 0; j < oldActiveBindings.length; j++) {
                    if (binding.equals(oldActiveBindings[j])) {
                        bindingFound = true;
                        break;
                    }
                }
                if (!bindingFound) {
                    applianceChanged = true;
                    break;
                }
            }
        }

        if (spChannel.activeProfiles.length != oldActiveProfiles.length) {
            applianceChanged = true;
        } else {
            for (var i:int = 0; i < spChannel.activeProfiles.length; i++) {
                var profile:ProfileDTO = spChannel.activeProfiles[i];
                var profileFound:Boolean = false;
                for (var j:int = 0; j < oldActiveProfiles.length; j++) {
                    if (profile.equals(oldActiveProfiles[j])) {
                        profileFound = true;
                        break;
                    }
                }
                if (!profileFound) {
                    applianceChanged = true;
                    break;
                }
            }
        }

        if (identityProvider.signAuthenticationAssertions != _ipContractSection.signAuthAssertionCheck.selected ||
                identityProvider.encryptAuthenticationAssertions != _ipContractSection.encryptAuthAssertionCheck.selected) {
            applianceChanged = true;
        }

        //identityProvider.defaultChannel = spChannel;
        identityProvider.signAuthenticationAssertions = _ipContractSection.signAuthAssertionCheck.selected;
        identityProvider.encryptAuthenticationAssertions = _ipContractSection.encryptAuthAssertionCheck.selected;

        if (applianceChanged) {
            sendNotification(ApplicationFacade.NOTE_IDENTITY_APPLIANCE_CHANGED);
        }
    }

    private function handleServiceProviderCorePropertyTabCreationComplete(event:Event):void {
        var serviceProvider:ServiceProviderDTO;

        serviceProvider = _currentIdentityApplianceElement as ServiceProviderDTO;
        // bind view
        _spCoreSection.serviceProvName.text = serviceProvider.name;
        _spCoreSection.serviceProvDescription.text = serviceProvider.description;
        //TODO

        for (var i:int = 0; i < _spCoreSection.spLocationProtocol.dataProvider.length; i++) {
            if (serviceProvider.location != null && _spCoreSection.spLocationProtocol.dataProvider[i].label == serviceProvider.location.protocol) {
                _spCoreSection.spLocationProtocol.selectedIndex = i;
                break;
            }
        }
        _spCoreSection.spLocationDomain.text = serviceProvider.location.host;
        _spCoreSection.spLocationPort.text = serviceProvider.location.port.toString();
        _spCoreSection.spLocationContext.text = serviceProvider.location.context;
        _spCoreSection.spLocationPath.text = serviceProvider.location.uri;
    }

    private function handleServiceProviderCorePropertyTabRollOut(e:Event):void {
        // bind model
        var serviceProvider:ServiceProviderDTO;

        serviceProvider = _currentIdentityApplianceElement as ServiceProviderDTO;

        serviceProvider.name = _spCoreSection.serviceProvName.text;
        serviceProvider.description = _spCoreSection.serviceProvDescription.text;

        var loc:LocationDTO = new LocationDTO();
        loc.protocol = _spCoreSection.spLocationProtocol.selectedLabel;
        loc.host = _spCoreSection.spLocationDomain.text;
        loc.port = parseInt(_spCoreSection.spLocationPort.text);
        loc.context = _spCoreSection.spLocationContext.text;
        loc.uri = _spCoreSection.spLocationPath.text;
        loc.uri = _spCoreSection.spLocationPath.text;
        serviceProvider.location = loc;

        // TODO save remaining fields to defaultChannel, calling appropriate lookup methods
        //userInformationLookup
        //authenticationContract
        //authenticationMechanism
        //authenticationAssertionEmissionPolicy

        sendNotification(ApplicationFacade.NOTE_DIAGRAM_ELEMENT_UPDATED);
    }

    private function handleServiceProviderContractPropertyTabCreationComplete(event:Event):void {

        var serviceProvider:ServiceProviderDTO;

        serviceProvider = _currentIdentityApplianceElement as ServiceProviderDTO;

//        _spContractSection.signAuthRequestCheck.selected = serviceProvider.signAuthenticationAssertions;
//        _spContractSection.encryptAuthRequestCheck.selected = serviceProvider.encryptAuthenticationAssertions;

        var defaultChannel:ChannelDTO = serviceProvider.defaultChannel;
        if (defaultChannel != null) {
            for (var j:int = 0; j < defaultChannel.activeBindings.length; j ++) {
                var tmpBinding:BindingDTO = defaultChannel.activeBindings.getItemAt(j) as BindingDTO;
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_POST.name) {
                    _spContractSection.samlBindingHttpPostCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_REDIRECT.name) {
                    _spContractSection.samlBindingHttpRedirectCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_ARTIFACT.name) {
                    _spContractSection.samlBindingArtifactCheck.selected = true;
                }
            }
            for (j = 0; j < defaultChannel.activeProfiles.length; j++) {
                var tmpProfile:ProfileDTO = defaultChannel.activeProfiles.getItemAt(j) as ProfileDTO;
                if (tmpProfile.name == ProfileDTO.SSO.name) {
                    _spContractSection.samlProfileSSOCheck.selected = true;
                }
                if (tmpProfile.name == ProfileDTO.SSO_SLO.name) {
                    _spContractSection.samlProfileSLOCheck.selected = true;
                }
            }
        }
    }

    private function handleServiceProviderContractPropertyTabRollOut(event:Event):void {

        var serviceProvider:ServiceProviderDTO;

        serviceProvider = _currentIdentityApplianceElement as ServiceProviderDTO;

        var idpChannel:IdentityProviderChannelDTO = serviceProvider.defaultChannel as IdentityProviderChannelDTO;
        if(idpChannel == null) {
            idpChannel = new IdentityProviderChannelDTO();
        }

        idpChannel.activeBindings = new ArrayCollection();
        if (_spContractSection.samlBindingHttpPostCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_POST);
        }
        if (_spContractSection.samlBindingArtifactCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_ARTIFACT);
        }
        if (_spContractSection.samlBindingHttpRedirectCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_REDIRECT);
        }

        idpChannel.activeProfiles = new ArrayCollection();
        if (_spContractSection.samlProfileSSOCheck.selected) {
            idpChannel.activeProfiles.addItem(ProfileDTO.SSO);
        }
        if (_spContractSection.samlProfileSLOCheck.selected) {
            idpChannel.activeProfiles.addItem(ProfileDTO.SSO_SLO);
        }

        serviceProvider.defaultChannel = idpChannel;
//        identityProvider.signAuthenticationAssertions = _ipContractSection.signAuthAssertionCheck.selected;
//        identityProvider.encryptAuthenticationAssertions = _ipContractSection.encryptAuthAssertionCheck.selected;

    }

    protected function enableIdpChannelPropertyTabs():void {
        // Attach idp channel editor form to property tabbed view
        _propertySheetsViewStack.removeAllChildren();

        // Core Tab
        var corePropertyTab:Canvas = new Canvas();
        corePropertyTab.id = "propertySheetCoreSection";
        corePropertyTab.label = "Core";
        corePropertyTab.width = Number("100%");
        corePropertyTab.height = Number("100%");
        corePropertyTab.setStyle("borderStyle", "solid");

        _idpChannelCoreSection = new IDPChannelCoreSection();
        corePropertyTab.addChild(_idpChannelCoreSection);
        _propertySheetsViewStack.addChild(corePropertyTab);

        _idpChannelCoreSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdpChannelCorePropertyTabCreationComplete);
        corePropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleIdpChannelCorePropertyTabRollOut);

        // Contract Tab
        var contractPropertyTab:Canvas = new Canvas();
        contractPropertyTab.id = "propertySheetContractSection";
        contractPropertyTab.label = "Contract";
        contractPropertyTab.width = Number("100%");
        contractPropertyTab.height = Number("100%");
        contractPropertyTab.setStyle("borderStyle", "solid");

        _idpChannelContractSection = new IDPChannelContractSection();
        contractPropertyTab.addChild(_idpChannelContractSection);
        _propertySheetsViewStack.addChild(contractPropertyTab);

        _idpChannelContractSection.addEventListener(FlexEvent.CREATION_COMPLETE, handleIdpChannelContractPropertyTabCreationComplete);
        contractPropertyTab.addEventListener(MouseEvent.ROLL_OUT, handleIdpChannelContractPropertyTabRollOut);
    }

    private function handleIdpChannelCorePropertyTabCreationComplete(event:Event):void {
        var idpChannel:IdentityProviderChannelDTO;

        idpChannel = _currentIdentityApplianceElement as IdentityProviderChannelDTO;
        // bind view
        _idpChannelCoreSection.identityProvChannelName.text = idpChannel.name;
        _idpChannelCoreSection.identityProvChannelDescription.text = idpChannel.description;
        //TODO

        for (var i:int = 0; i < _idpChannelCoreSection.idpChannelLocationProtocol.dataProvider.length; i++) {
            if (idpChannel.location != null && _idpChannelCoreSection.idpChannelLocationProtocol.dataProvider[i].label == idpChannel.location.protocol) {
                _idpChannelCoreSection.idpChannelLocationProtocol.selectedIndex = i;
                break;
            }
        }
        _idpChannelCoreSection.idpChannelLocationDomain.text = idpChannel.location.host;
        _idpChannelCoreSection.idpChannelLocationPort.text = idpChannel.location.port.toString();
        _idpChannelCoreSection.idpChannelLocationContext.text = idpChannel.location.context;
        _idpChannelCoreSection.idpChannelLocationPath.text = idpChannel.location.uri;
    }

    private function handleIdpChannelCorePropertyTabRollOut(e:Event):void {
        // bind model
        var idpChannel:IdentityProviderChannelDTO;

        idpChannel = _currentIdentityApplianceElement as IdentityProviderChannelDTO;

        idpChannel.name = _idpChannelCoreSection.identityProvChannelName.text;
        idpChannel.description = _idpChannelCoreSection.identityProvChannelDescription.text;

        if(idpChannel.location == null){
            idpChannel.location = new LocationDTO();
        }
        
        idpChannel.location.protocol = _idpChannelCoreSection.idpChannelLocationProtocol.selectedLabel;
        idpChannel.location.host = _idpChannelCoreSection.idpChannelLocationDomain.text;
        idpChannel.location.port = parseInt(_idpChannelCoreSection.idpChannelLocationPort.text);
        idpChannel.location.context = _idpChannelCoreSection.idpChannelLocationContext.text;
        idpChannel.location.uri = _idpChannelCoreSection.idpChannelLocationPath.text;

        // TODO save remaining fields to defaultChannel, calling appropriate lookup methods
        //userInformationLookup
        //authenticationContract
        //authenticationMechanism
        //authenticationAssertionEmissionPolicy

        sendNotification(ApplicationFacade.NOTE_DIAGRAM_ELEMENT_UPDATED);
    }

    private function handleIdpChannelContractPropertyTabCreationComplete(event:Event):void {

        var idpChannel:IdentityProviderChannelDTO;

        idpChannel = _currentIdentityApplianceElement as IdentityProviderChannelDTO;

//        _spContractSection.signAuthRequestCheck.selected = serviceProvider.signAuthenticationAssertions;
//        _spContractSection.encryptAuthRequestCheck.selected = serviceProvider.encryptAuthenticationAssertions;

        if (idpChannel != null) {
            for (var j:int = 0; j < idpChannel.activeBindings.length; j ++) {
                var tmpBinding:BindingDTO = idpChannel.activeBindings.getItemAt(j) as BindingDTO;
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_POST.name) {
                    _idpChannelContractSection.samlBindingHttpPostCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_HTTP_REDIRECT.name) {
                    _idpChannelContractSection.samlBindingHttpRedirectCheck.selected = true;
                }
                if (tmpBinding.name == BindingDTO.SAMLR2_ARTIFACT.name) {
                    _idpChannelContractSection.samlBindingArtifactCheck.selected = true;
                }
            }
            for (j = 0; j < idpChannel.activeProfiles.length; j++) {
                var tmpProfile:ProfileDTO = idpChannel.activeProfiles.getItemAt(j) as ProfileDTO;
                if (tmpProfile.name == ProfileDTO.SSO.name) {
                    _idpChannelContractSection.samlProfileSSOCheck.selected = true;
                }
                if (tmpProfile.name == ProfileDTO.SSO_SLO.name) {
                    _idpChannelContractSection.samlProfileSLOCheck.selected = true;
                }
            }
        }
    }

    private function handleIdpChannelContractPropertyTabRollOut(event:Event):void {

        var idpChannel:IdentityProviderChannelDTO;

        idpChannel = _currentIdentityApplianceElement as IdentityProviderChannelDTO;

        idpChannel.activeBindings = new ArrayCollection();
        if (_idpChannelContractSection.samlBindingHttpPostCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_POST);
        }
        if (_idpChannelContractSection.samlBindingArtifactCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_ARTIFACT);
        }
        if (_idpChannelContractSection.samlBindingHttpRedirectCheck.selected) {
            idpChannel.activeBindings.addItem(BindingDTO.SAMLR2_HTTP_REDIRECT);
        }

        idpChannel.activeProfiles = new ArrayCollection();
        if (_idpChannelContractSection.samlProfileSSOCheck.selected) {
            idpChannel.activeProfiles.addItem(ProfileDTO.SSO);
        }
        if (_idpChannelContractSection.samlProfileSLOCheck.selected) {
            idpChannel.activeProfiles.addItem(ProfileDTO.SSO_SLO);
        }

//        identityProvider.signAuthenticationAssertions = _ipContractSection.signAuthAssertionCheck.selected;
//        identityProvider.encryptAuthenticationAssertions = _ipContractSection.encryptAuthAssertionCheck.selected;
        
    }


    protected function clearPropertyTabs():void {
        // Attach appliance editor form to property tabbed view
        _propertySheetsViewStack.removeAllChildren();

    }

    protected function get view():PropertySheetView
    {
        return viewComponent as PropertySheetView;
    }


}
}