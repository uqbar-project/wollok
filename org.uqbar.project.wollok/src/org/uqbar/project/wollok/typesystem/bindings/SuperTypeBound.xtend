package org.uqbar.project.wollok.typesystem.bindings

import org.uqbar.project.wollok.semantics.WollokType

/**
 * The target node is the same or a super type of
 * the bounded node
 * 
 * type(from) >= type(to)
 * 
 * @author jfernandes
 */
class SuperTypeBound extends TypeBound {
	TypedNode bindSource
	
	new(TypedNode from, TypedNode to) {
		super(from, to)
	}
	
	new(TypedNode bindSource, TypedNode from, TypedNode to) {
		super(from, to)
		this.bindSource = bindSource
	}
	
	override toTypeChanged(WollokType newType) {
		// TODO: esto esta incompleto.
		// a futuro hay que modelar al abstractType SuperWollokType
		// que representa un tipo aun no resuelto, pero que tiene una constraint.
		// los tipos no resueltos se pueden refinar luego. Los fijos o concretos no (?)
		
		// en lugar de asignar, no debería setear una expectation (?)
		propagate [
			try	{
				from.assignType(newType)
			}
			catch (TypeExpectationFailedException e) {
				e.model = bindSource.model
				bindSource.addError(e)		
			}
		]
	}
	
	override fromTypeChanged(WollokType newType) {
		propagate [
			try	 {
				to.assignType(newType)
			}
			catch (TypeExpectationFailedException e) {
				e.model = bindSource.model
				bindSource.addError(e)		
			} 
		]
	}
	
	override toString() {
		'''«from» extends «to»'''
	}
	
}