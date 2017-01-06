package org.uqbar.project.wollok.typesystem.constraints

class SealVariables extends AbstractInferenceStrategy {
	override analiseVariable(TypeVariable tvar) {
		if (!tvar.sealed && tvar.subtypes.forall[sealed]) {
			tvar.beSealed
			println('''	Sealing «tvar» with type «tvar.minimalConcreteTypes»''')
			changed = true
		}
	}
}