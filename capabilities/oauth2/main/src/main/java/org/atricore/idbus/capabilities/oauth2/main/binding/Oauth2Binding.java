package org.atricore.idbus.capabilities.oauth2.main.binding;

/**
 * @author <a href=mailto:sgonzalez@atricore.org>Sebastian Gonzalez Oyuela</a>
 */
public enum Oauth2Binding {

    /** URI for IDBUS SOAP binding, this is NOT SAML Normtive */
    OAUTH2_SOAP("urn:org:atricore:idbus:oauth2:bindings:SOAP", false),

    OAUTH2_RESTFUL("urn:org:atricore:idbus:oauth2:bindings:RESTFUL", true);


    private String binding;
    boolean frontChannel;

    Oauth2Binding(String binding, boolean frontChannel) {
        this.binding = binding;
        this.frontChannel = frontChannel;
    }

    public String getValue() {
        return binding;
    }

    @Override
    public String toString() {
        return binding;
    }

    public boolean isFrontChannel() {
        return frontChannel;
    }

    public static Oauth2Binding asEnum(String binding) {
        for (Oauth2Binding b : values()) {
            if (b.getValue().equals(binding))
                return b;
        }

        throw new IllegalArgumentException("Invalid Oauth2Binding '" + binding + "'");
    }

}
