package org.uqbar.project.wollok.typesystem

import org.uqbar.project.wollok.wollokDsl.WClass

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.typesystem.TypeSystem

/**
 * 
 * @author jfernandes
 */
class ClassBasedWollokType extends BasicType implements ConcreteType {
	WClass clazz
	TypeSystem typeSystem
	
	new(WClass clazz, TypeSystem typeSystem) {
		super(clazz.name)
		this.clazz = clazz
		this.typeSystem = typeSystem
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
		val m = clazz.lookupMethod(message.name, message.parameterTypes, true)
		// TODO: por ahora solo checkea misma cantidad de parametros
		// 		debería en realidad checkear tipos !  
		if (m != null && m.parameters.size == message.parameterTypes.size)
			m
		else
			null
	}
	
	override resolveReturnType(MessageType message) {
		val method = lookupMethod(message)
		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir
		typeSystem.type(method)
	}
	
	// ***************************************************************************
	// ** REFINEMENT: how it affects a previous inferred type once 
	// ** the var is later assigned to this type.
	// ***************************************************************************
	
	override refine(WollokType previouslyInferred) {
		doRefine(previouslyInferred)
	}
	
	// by default uses super
	def dispatch doRefine(WollokType previous) {
		super.refine(previous)
	}
	
	def dispatch doRefine(ClassBasedWollokType previous) {
		val commonType = commonSuperclass(clazz, previous.clazz)
		if (commonType == null)
			throw new TypeSystemException("Incompatible types. Expected " + previous.name + " <=> " + name)
		new ClassBasedWollokType(commonType, typeSystem)
	}
	
	def dispatch doRefine(ObjectLiteralWollokType previous) {
		val intersectMessages = allMessages.filter[previous.understandsMessage(it)]
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
		clazz.allMethods.map[m| typeSystem.queryMessageTypeForMethod(m)]
	}
	
	// *******************************
	// ** object
	// *******************************
	
	override equals(Object obj) { 
		obj instanceof ClassBasedWollokType && (obj as ClassBasedWollokType).clazz == clazz
	}
	
	override hashCode() { clazz.hashCode }
	
}