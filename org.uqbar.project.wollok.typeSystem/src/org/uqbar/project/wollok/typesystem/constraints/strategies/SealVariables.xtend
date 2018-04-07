package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.WollokTypeExtension.*

class SealVariables extends AbstractInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)
	
	override analiseVariable(TypeVariable it) {
		if (!sealed && shouldBeSealed) {
			beSealed
			log.debug('''	Sealing «it» with type «type»''')
			changed = true
		}
	}
	
	def shouldBeSealed(TypeVariable it) {
		!subtypes.empty 
		&& subtypes.forall[sealed] 
		&& !type.isAny 
	}
}
