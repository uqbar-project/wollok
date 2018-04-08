package org.uqbar.project.wollok.typesystem

import java.util.List
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClassBasedWollokType extends AbstractContainerWollokType {
	
	new(WClass clazz, TypeSystem typeSystem) {
		super(clazz, typeSystem)
	}
	
	def clazz() { container as WClass }
	
	def WConstructor getConstructor(List<?> parameterTypes) {
		clazz.getOwnConstructor(parameterTypes.size)
	}	
	
	override acceptsAssignment(WollokType other) {
		this == other ||
			// hackeo por ahora. Esto no permite compatibilidad entre classes y structural types
			(other instanceof ClassBasedWollokType
				&& clazz.isSuperTypeOf((other as ClassBasedWollokType).clazz)
			)
	}

	override acceptAssignment(WollokType other) {
		if (!acceptsAssignment(other))
			throw new TypeSystemException('''<<«other»>> is not a valid substitute for <<«this»>>''')	
	}
	
	// ***************************************************************************
	// ** REFINEMENT: how it affects a previous inferred type once 
	// ** the var is later assigned to this type.
	// ***************************************************************************
	
	def dispatch refine(ClassBasedWollokType previous) {
		val commonType = commonSuperclass(clazz, previous.clazz)
		if (commonType === null)
			throw new TypeSystemException("Incompatible types. Expected " + previous.name + " <=> " + name)
		new ClassBasedWollokType(commonType, typeSystem)
	}
	
	def dispatch refine(ObjectLiteralWollokType previous) {
		val intersectMessages = allMessages.filter[previous.understandsMessage(it)]
		new StructuralType(intersectMessages.iterator)
	}
	
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
	
}