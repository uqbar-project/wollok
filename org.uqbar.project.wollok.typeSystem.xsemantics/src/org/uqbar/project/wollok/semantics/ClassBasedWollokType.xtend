package org.uqbar.project.wollok.semantics

import it.xsemantics.runtime.RuleEnvironment
import org.uqbar.project.wollok.wollokDsl.WClass

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClassBasedWollokType extends BasicType implements ConcreteType {
	WClass clazz
	WollokDslTypeSystem system
	RuleEnvironment env

	new(WClass clazz, WollokDslTypeSystem system, RuleEnvironment env) {
		super(clazz.name)
		this.clazz = clazz
		this.system = system
		this.env = env
	}
	
	override understandsMessage(MessageType message) {
		lookupMethod(message) != null
	}
	
	override acceptAssignment(WollokType other) {
		val value = this == other ||
			// hackeo por ahora. Esto no permite compatibilidad entre classes y structural types
			(other instanceof ClassBasedWollokType
				&& clazz.isSuperTypeOf((other as ClassBasedWollokType).clazz)
			)
		if (!value)
			throw new TypeSystemException('''<<«other»>> is not a valid substitude for <<«this»>>''')	
	}
	
	override lookupMethod(MessageType message) {
		val m = clazz.lookupMethod(message.name)
		// TODO: por ahora solo checkea misma cantidad de parametros
		// 		debería en realidad checkear tipos !  
		if (m != null && m.parameters.size == message.parameterTypes.size)
			m
		else
			null
	}
	
	override resolveReturnType(MessageType message, WollokDslTypeSystem system, RuleEnvironment g) {
		val method = lookupMethod(message)
		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir
		system.env(g, method, WollokType)
	}
	
	// ***************************************************************************
	// ** REFINEMENT: how it affects a previous inferred type once 
	// ** the var is later assigned to this type.
	// ***************************************************************************
	
	override refine(WollokType previouslyInferred, RuleEnvironment g) {
		doRefine(previouslyInferred, g)
	}
	
	// by default uses super
	def dispatch doRefine(WollokType previous, RuleEnvironment g) {
		super.refine(previous, g)
	}
	
	def dispatch doRefine(ClassBasedWollokType previous, RuleEnvironment g) {
		val commonType = commonSuperclass(clazz, previous.clazz)
		if (commonType == null)
			throw new TypeSystemException("Incompatible types. Expected " + previous.name + " <=> " + name)
		new ClassBasedWollokType(commonType, system, env)
	}
	
	def dispatch doRefine(ObjectLiteralWollokType previous, RuleEnvironment g) {
		val intersectMessages = getAllMessages(g).filter[previous.understandsMessage(it)]
		new StructuralType(intersectMessages.iterator)
	}
	
	//
	
	def WClass commonSuperclass(WClass a, WClass b) {
		if (a.isSubclassOf(b))
			b
		else if (b.isSubclassOf(a))
			a
		else
			commonSuperclass(a.parent, b.parent)
	}
	
	def boolean isSubclassOf(WClass potSub, WClass potSuper) {
		potSub == potSuper || (noneAreNull(potSub, potSuper) && potSub.parent.isSubclassOf(potSuper))   
	}
	
	override getAllMessages() {
		getAllMessages(env)
	}
	
	def getAllMessages(RuleEnvironment g) {
		clazz.allMethods.map[m| system.queryMessageTypeForMethod(g, m).first]
	}
	
	// *******************************
	// ** object
	// *******************************
	
	override equals(Object obj) { 
		obj instanceof ClassBasedWollokType && (obj as ClassBasedWollokType).clazz == clazz
	}
	
	override hashCode() { clazz.hashCode }
	
}