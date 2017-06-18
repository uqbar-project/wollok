package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

class SealVariables extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if (!tvar.sealed && !tvar.subtypes.empty && tvar.subtypes.forall[sealed]) {
			tvar.beSealed
			println('''	Sealing «tvar» with type «tvar.minimalConcreteTypes»''')
			changed = true
		}
	}
}
