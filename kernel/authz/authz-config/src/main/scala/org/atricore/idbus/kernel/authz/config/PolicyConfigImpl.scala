package org.atricore.idbus.kernel.authz.config

import org.springframework.core.io.Resource
import reflect.BeanProperty

class PolicyConfigImpl extends PolicyConfig {

  @BeanProperty var policyResource: Resource = _

}
