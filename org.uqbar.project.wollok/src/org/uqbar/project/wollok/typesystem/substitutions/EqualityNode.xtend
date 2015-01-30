package org.uqbar.project.wollok.typesystem.substitutions

import org.eclipse.emf.ecore.EObject

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*
import org.uqbar.project.wollok.semantics.WollokType

/**
 * Model wrapper.
 * Kind of a "state" pattern for each side of an EqualsTypeRule.
 * Because the rule tries to solve types then sometimes a rule starts 
 * as an unknown type and then gets resolved based on another rule.
 * Example
 * 
 * 		t(a) == t(b)      	>     UnknownType(a) == UnknownType(b)
 * 
 * 	Plus other rule:   "var a = 23" = Int, then:
 * 
 * 		Int == t(b)			>		Fact(a = Int) == UnknownType(b)
 * 
 * @author jfernandes
 */
abstract class EqualityNode {
	@Property EObject model
	
	new(EObject object) { this.model = object }
	
	def boolean tryToResolve(SubstitutionBasedTypeSystem system, CheckTypeRule rule)
	def WollokType getType() { null }
	
	def boolean isNonTerminalFor(Object obj);
	
	override hashCode() { model.hashCode }
}

/**
 * An unknown model's type.
 * 
 * @author jfernandes
 */
class UnknownNode extends EqualityNode {
	new(EObject object) { super(object) }
	
	override tryToResolve(SubstitutionBasedTypeSystem system, CheckTypeRule rule) {
		val type = system.typeForExcept(model, rule)
		if (type != null) {
			rule.changeNode(this, new ResolvedTypeNode(model, type))
			true
		}
		else
			false
	}
	
	override isNonTerminalFor(Object obj) { model == obj }
	
	override toString() { '''t(«model.sourceCode.trim»)''' }
	
	override equals(Object obj) { obj instanceof UnknownNode && model == (obj as UnknownNode).model }

}

/**
 * Already solved model's type.
 * 
 * @author jfernandes
 */
class ResolvedTypeNode extends EqualityNode {
	WollokType type
	
	new(EObject model, WollokType type) {
		super(model)
		this.type = type
	}
	
	override tryToResolve(SubstitutionBasedTypeSystem system, CheckTypeRule rule) { false }
	override isNonTerminalFor(Object obj) { false }
	
	override getType() { type }
	
	// object
	override toString() { type.name }
	override equals(Object obj) {
		obj instanceof ResolvedTypeNode && model == (obj as ResolvedTypeNode).model && type == (obj as ResolvedTypeNode).type
	}
	
	override hashCode() { super.hashCode / type.hashCode }

}