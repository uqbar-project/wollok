package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

class SealVariables extends AbstractInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)
	
	override analiseVariable(TypeVariable tvar) {
		if (!tvar.sealed && !tvar.subtypes.empty && tvar.subtypes.forall[sealed]) {
			tvar.beSealed
			log.debug('''	Sealing «tvar» with type «tvar.type»''')
			changed = true
		}
	}
}
