package org.atricore.idbus.kernel.main.provisioning.domain;

import java.io.Serializable;

/**
 * @author <a href=mailto:gbrigandi@atricore.org>Gianluca Brigandi</a>
 */
public class Acl implements Serializable {

    private static final long serialVersionUID = 4595183658527599864L;

    private Long id;
    private String name;
    private String description;

    private AclEntry[] entries;
    
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }


    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public AclEntry[] getEntries() {
        return entries;
    }

    public void setAclEntries(AclEntry[] entries) {
        this.entries = entries;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Acl)) return false;

        Acl that = (Acl) o;

        if(id == 0) return false;

        if (id != that.id) return false;

        return true;
    }

    @Override
    public int hashCode() {
        return (int) (id ^ (id >>> 32));
    }
}