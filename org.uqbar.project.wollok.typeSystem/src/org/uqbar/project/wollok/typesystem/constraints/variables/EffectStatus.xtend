package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*
import org.uqbar.project.wollok.wollokDsl.WNamedObject

@Accessors
abstract class EffectStatus {
	val EObject context

	def static Change() { new Change(null) }

	def static Change(EObject context) { new Change(context) }

	def static Nothing() { new Nothing() }

	def static ThrowException() { new ThrowException() }

	def static Undefined() { new Undefined() }

	new() {
		this.context = null
	}

	new(EObject context) {
		this.context = context
	}

	def abstract String name()

	def sameName(EffectStatus status) {
		this.name == status.name
	}
}

class Change extends EffectStatus {

	new(EObject context) {
		super(context)
	}

	override name() { '''Change''' }

}

class Nothing extends EffectStatus {

	override name() { '''Nothing''' }

}

class ThrowException extends EffectStatus {

	override name() { '''ThrowException''' }

}

class Undefined extends EffectStatus {

	override name() { '''Undefined''' }

}

class EffectStatusExtensions {
	static def join(EffectStatus s1, EffectStatus s2, TypeVariable tvar) {
		// TODO: Union change status
		if(s1.sameName(Change)) return s1.contextualizeChange(s2, tvar)
		if(s2.sameName(Change)) return s2.contextualizeChange(s1, tvar)
		if(s1.sameName(Undefined)) s2 else s1
	}

	static def contextualizeChange(EffectStatus change, EffectStatus other, TypeVariable tvar) {
		if (change.context === null || change.context.isGlobal) { // Global change
			return change
		}
		if (tvar.contextAffects(change.context)) {
			return change
		} else {
			return other
		}

	}

	static def contextAffects(TypeVariable tvar, EObject changeContext) {
		(tvar.owner as ProgramElementTypeVariableOwner).programElement.context.includesContext(changeContext)
	}

	static def Boolean includesContext(EObject tvarContext, EObject changeContext) {
		tvarContext !== null && (tvarContext == changeContext || tvarContext.context.includesContext(changeContext))
	}

	static def context(EObject it) { eContainer }

	static dispatch def isGlobal(EObject it) { false }
	static dispatch def isGlobal(WNamedObject it) { true }

}
