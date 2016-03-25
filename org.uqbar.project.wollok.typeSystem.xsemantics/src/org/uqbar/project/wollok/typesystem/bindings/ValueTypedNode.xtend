package org.uqbar.project.wollok.typesystem.bindings

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.WollokType

/**
 * A Typed node representing a "leaf" node.
 * That's an AST element which has a fixed type.
 * For example, a literal.
 * 
 * If the language supports explicit types then those would also be
 * ValueTypedNode.
 * 
 * @author jfernandes
 */
class ValueTypedNode extends TypedNode {
	WollokType fixedType
	
	new(EObject object, WollokType type, BoundsBasedTypeSystem s) {
		super(object, s)
		fixedType = type
	}
	
	override getType() { fixedType }
	
	override assignType(WollokType type) {
		if (type != fixedType)
			throw new TypeExpectationFailedException('''Expected <<«fixedType»>> but found <<«type»>>''')
	}
	
	override inferTypes() {
		fireTypeChanged
	}
	
	override toString() { '''FixedType(«fixedType.name»)''' }
	
}