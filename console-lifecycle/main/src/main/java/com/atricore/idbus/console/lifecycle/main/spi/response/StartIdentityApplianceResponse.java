package com.atricore.idbus.console.lifecycle.main.spi.response;

import com.atricore.idbus.console.lifecycle.main.domain.IdentityAppliance;

/**
 * @author <a href="mailto:sgonzalez@atricore.org">Sebastian Gonzalez Oyuela</a>
 * @version $Id$
 */
public class StartIdentityApplianceResponse extends AbstractManagementResponse {

    private IdentityAppliance appliance;

    public StartIdentityApplianceResponse() {
    }

    public StartIdentityApplianceResponse(IdentityAppliance appliance) {
        this.appliance = appliance;
    }

    public IdentityAppliance getAppliance() {
        return appliance;
    }

    public void setAppliance(IdentityAppliance appliance) {
        this.appliance = appliance;
    }
}
