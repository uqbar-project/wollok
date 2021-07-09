package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.UnionType
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.typesystem.constraints.variables.MessageSend
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
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
	TypeVariable tvar

	new(TypeVariable tvar) {
		this.tvar = tvar
	}

	def commonSupertype(Iterable<WollokType> types, Iterable<MessageSend> messages) {
		types.reduce [ t1, t2 |
			if (t1.isSubtypeOf(t2))
				t2
			else if(t2.isSubtypeOf(t1)) t1 else t1.commonSupertypeWith(t2, messages)
		]
	}

	/** 
	 * Basic implementation delegates in traditional WollokType#refine
	 */
	def dispatch commonSupertypeWith(WollokType t1, WollokType t2, Iterable<MessageSend> messages) {
		t1.refine(t2)
	}

	def dispatch commonSupertypeWith(ConcreteType t1, ConcreteType t2, Iterable<MessageSend> messages) {
		t1.commonSuperClassWith(t2, messages) ?: new UnionType(t1, t2)
	}

	def dispatch commonSupertypeWith(UnionType t1, ConcreteType t2, Iterable<MessageSend> messages) {
		new UnionType(#[t2] + t1.types.reject[t1.isSubtypeOf(t2)])
	}

	// ************************************************************************
	// ** Subtype relationships
	// ************************************************************************
	/**
	 * TODO Missing cases for non container-based types
	 */
	def dispatch boolean isSubtypeOf(WollokType t1, WollokType t2) {
		false
	}

	/**
	 * A union type is subtype of a container if all of its elements are subtypes of the container.
	 */
	def dispatch boolean isSubtypeOf(UnionType t1, ConcreteType t2) {
		t1.types.forall[isSubtypeOf(t2)]
	}

	/**
	 * A container type is subclass of union type if it is subclass of any type in the union.
	 */
	def dispatch boolean isSubtypeOf(ConcreteType t1, UnionType t2) {
		t2.types.exists[t1.isSubtypeOf(it)]
	}

	def dispatch boolean isSubtypeOf(ConcreteType t1, ConcreteType t2) {
		t1.container.isSubclassOf(t2.container)
	}

	def boolean isSubclassOf(WMethodContainer potSub, WMethodContainer potSuper) {
		potSub == potSuper || (noneAreNull(potSub, potSuper) && potSub.parent.isSubclassOf(potSuper))
	}

	// ************************************************************************
	// ** Containers
	// ************************************************************************
	def WollokType commonSuperClassWith(ConcreteType t1, ConcreteType t2, Iterable<MessageSend> messages) {
		if (t1.isSubtypeOf(t2))
			t2
		else if (t2.isSubtypeOf(t1))
			t1
		else {
			val p1 = t1.parentType
			val p2 = t2.parentType
			if (p1 !== null && p1.name != "Object" && p1.respondsToAll(messages, true) && p2 !== null &&
				p2.name != "Object" && p2.respondsToAll(messages, true)) {
				commonSuperClassWith(p1, p2, messages)
			} else
				null // There is no common super class, use another strategy (e.g. union types or structural types).
		}
	}

	def parentType(ConcreteType type) {
		// TODO #1427 Instanciar el tipo encontrado instanciando correctamente según las subclases.
		(type.typeSystem as ConstraintBasedTypeSystem).typeOrFactory(type.container.parent).instanceFor(tvar)
	}
}
