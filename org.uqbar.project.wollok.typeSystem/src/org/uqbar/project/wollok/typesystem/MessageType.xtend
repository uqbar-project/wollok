package org.uqbar.project.wollok.typesystem

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * 
 * @author jfernandes
 */
@Accessors
class MessageType {
	String name
	List<WollokType> parameterTypes
	WollokType returnType
	
	new(String name, List<WollokType> parameterTypes, WollokType returnType) {
		this.name = name
		this.parameterTypes = parameterTypes
		this.returnType = returnType
	}
	
	override equals(Object obj) {
		if (obj instanceof MessageType)
			this.isSubtypeof(obj)
		else 
			false
	}
	
	override toString() {
		name + if (parameterTypes.empty) "" else ('(' + parameterTypes.join(',') + ')')
			+ if (returnType != null && returnType != WollokType.WVoid) (" : " + returnType) else ""			
	}
	
	/**
	 * tells whether this message type can be considered polymorphic
	 * with the given message.
	 * No matter if parameter types are exactly the same type.
	 * But each param type should be "compatible" with the given's.
	 * For example
	 * 
	 *  train(Dog d)  isSubtypeof   train(Animal a)
	 *  
	 *  train(Dog d)  isSubtypeof     < itself >
	 *  
	 *  learn(Trick t, Master m)   isSubtypeof    learn(MoveTailTrick t, GoodMaster m)
	 *  
	 */
	def isSubtypeof(MessageType obj) {
		name == obj.name 
		&& parameterTypes.size == obj.parameterTypes.size
		&& (
			parameterTypes.size == 0
			|| parameterTypes.zip(obj.parameterTypes)[mineT, otherT|
				try {
					otherT.acceptAssignment(mineT)
					true
				} catch (TypeSystemException e)
					false
			].forall[it]
		)
	}
	
}