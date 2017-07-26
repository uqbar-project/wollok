package org.uqbar.project.wollok.typesystem.constraints.types

import org.uqbar.project.wollok.typesystem.WollokType

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
	static def commonSupertype(Iterable<WollokType> types) {
		types.reduce[t1, t2|t1.supertypeWith(t2)]
	}

	/** 
	 * Basic implementation delegates in traditional WollokType#refine
	 */
	static def dispatch supertypeWith(WollokType t1, WollokType t2) {
		return t1.refine(t2)
	}
}
