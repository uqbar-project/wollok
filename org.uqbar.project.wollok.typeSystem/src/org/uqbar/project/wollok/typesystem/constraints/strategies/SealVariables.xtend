package org.uqbar.project.wollok.typesystem.constraints.strategies

import org.apache.log4j.Logger
import org.uqbar.project.wollok.typesystem.constraints.variables.GenericTypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeInfo
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable

import static extension org.uqbar.project.wollok.typesystem.WollokTypeExtension.*

class SealVariables extends SimpleTypeInferenceStrategy {
	val Logger log = Logger.getLogger(this.class)

	override dispatch void analiseVariable(TypeVariable it, TypeInfo typeInfo) {
		if (sealed || !shouldBeSealed) {
			return
		}
		sealVariable
	}

	def dispatch void analiseVariable(TypeVariable tvar, GenericTypeInfo typeInfo) {
		if (tvar.sealed || !tvar.shouldBeSealed) {
			return
		}

		typeInfo.validMinTypes.forEach [
			typeInfo.validateCompatibleMinType(it, tvar)
		]
		tvar.sealVariable
	}

	def sealVariable(TypeVariable it) {
		beSealed
		log.debug('''	Sealing «it» with type «type»''')
		changed = true
	}

	def shouldBeSealed(TypeVariable it) {
		!subtypes.empty && !owner.isParameter // TODO: use polymorphism?
		&& subtypes.forall[sealed] && !type.isAny
	}
}
