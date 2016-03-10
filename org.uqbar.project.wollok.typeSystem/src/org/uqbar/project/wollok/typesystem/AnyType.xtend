package org.uqbar.project.wollok.typesystem

/**
 * @author jfernandes
 */
// el .semantics no me deja hacer la regla ~~ con WollokType, no genera codigo y se rompe :
class AnyType extends BasicType implements WollokType {
	
	new() {
		super("Any")
	}
	
	override acceptAssignment(WollokType other) {}
	override understandsMessage(MessageType message) { true }
	
}