package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors

import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WReferenciable

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*
import org.uqbar.project.wollok.wollokDsl.WVariableReference

@Accessors
abstract class EffectStatus {
	val ITypeVariable context

	def static Change() { new Change(null) }

	def static Change(ITypeVariable context) { new Change(context) }

	def static Nothing() { new Nothing() }

	def static ThrowException() { new ThrowException() }

	def static Undefined() { new Undefined() }

	new() {
		this.context = null
	}

	new(ITypeVariable context) {
		this.context = context
	}

	def abstract String name()

	def sameName(EffectStatus status) {
		this.name == status.name
	}
}

class Change extends EffectStatus {

	new(ITypeVariable context) {
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
	@Accessors
	static extension TypeVariablesRegistry registry
	
	static def join(EffectStatus s1, EffectStatus s2, TypeVariable tvar) {
		// TODO: Union change status
		if(s1.sameName(Change)) return s1.contextualizeChange(s2, tvar)
		if(s2.sameName(Change)) return s2.contextualizeChange(s1, tvar)
		if(s1.sameName(Undefined)) s2 else s1
	}

	static def contextualizeChange(EffectStatus change, EffectStatus other, TypeVariable tvar) {
		val context = change.context
		if (context === null || context.programElement.isGlobal) { // Global change
			return change
		}
		if (tvar.contextAffects(context)) {
			return change
		} else if (tvar.contextInstance(context)) {
			val instance = context.instanceFor(tvar) 
			return Change(instance.programElement.context.tvar)
		} else {
			return other
		}

	}

	static def contextInstance(TypeVariable tvar, ITypeVariable changeContext) {
		val instance = changeContext.instanceFor(tvar)
		val target = instance.programElement
		val context = target.context
		instance !== changeContext && //TODO: Usar instance cuando viene un param
		(target.isGlobal || tvar.contextAffects(context))
	}

	static def contextAffects(TypeVariable tvar, ITypeVariable changeContext) {
		tvar.contextAffects(changeContext.programElement)
	}
	
	static def contextAffects(TypeVariable tvar, EObject changeContext) {
		tvar.programElement.eContainer.includesContext(changeContext)
	}

	static def Boolean includesContext(EObject tvarContext, EObject changeContext) {
		tvarContext !== null && (tvarContext == changeContext || tvarContext.eContainer.includesContext(changeContext))
	}
	
	static dispatch def EObject context(EObject it) { eContainer }
	static dispatch def EObject context(WVariableReference it) { ref.context }
	static dispatch def EObject context(WReferenciable it) { declarationContext	}

	static def programElement(ITypeVariable it) { (owner as ProgramElementTypeVariableOwner).programElement }

	static dispatch def isGlobal(EObject it) { false }
	static dispatch def isGlobal(WNamedObject it) { true }

}
