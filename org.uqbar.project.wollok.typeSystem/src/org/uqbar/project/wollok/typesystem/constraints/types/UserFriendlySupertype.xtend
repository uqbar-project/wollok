package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.AbstractContainerWollokType
import org.uqbar.project.wollok.typesystem.UnionType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.typesystem.constraints.types.MessageLookupExtensions.*

/**
 * In our constraint based type system, a type is a set of constraints (most significantly minTypes and messages/maxTypes).
 * This information is useful for type inference but not easy to read for users.
 * 
 * This class takes a set of basic (min)types and computes a simplified supertype, which should be suitable for informing the user
 * about the inferred types and errors. More specific tools (such as diagrams) might prefer to use raw type system information.
 * 
 * The selection of how to inform a type to the user has to be fed from actual class experience, this is just a first implementation.
 */
class UserFriendlySupertype {
	static def commonSupertype(Iterable<WollokType> types, Iterable<MessageSend> messages) {
		types.reduce[t1, t2|t1.supertypeWith(t2, messages)]
	}

	/** 
	 * Basic implementation delegates in traditional WollokType#refine
	 */
	static def dispatch supertypeWith(WollokType t1, WollokType t2, Iterable<MessageSend> messages) {
		t1.refine(t2)
	}

	static def dispatch supertypeWith(AbstractContainerWollokType t1, AbstractContainerWollokType t2, Iterable<MessageSend> messages) {
		t1.commonSuperClassWith(t2, messages) ?: new UnionType(t1, t2)
	}
	
	static def WollokType commonSuperClassWith(AbstractContainerWollokType t1, AbstractContainerWollokType t2, Iterable<MessageSend> messages) {
		if (t1.container.isSubclassOf(t2.container)) t2
		else if (t2.container.isSubclassOf(t1.container)) t1
		else {
			val p1 = t1.parentType
			val p2 = t2.parentType
			if (p1 !== null && p1.name != "Object" && p1.respondsToAll(messages) && 
				p2 !== null && p2.name != "Object" && p2.respondsToAll(messages)
			) {
				commonSuperClassWith(p1, p2, messages)
			}
			else null // There is no common super class, use another strategy (e.g. union types or structural types).
		}
	}
	
	def static boolean isSubclassOf(AbstractContainerWollokType t1, AbstractContainerWollokType t2) {
		t1.container.isSubclassOf(t2.container)
	}

	def static boolean isSubclassOf(WMethodContainer potSub, WMethodContainer potSuper) {
		potSub == potSuper || (noneAreNull(potSub, potSuper) && potSub.parent.isSubclassOf(potSuper)) 
	}

	// TODO Why parent is WMethodContainer and not WClass??
	def static parentType(AbstractContainerWollokType type) {
		(type.typeSystem as ConstraintBasedTypeSystem).classType(type.container.parent as WClass)
	}
}
