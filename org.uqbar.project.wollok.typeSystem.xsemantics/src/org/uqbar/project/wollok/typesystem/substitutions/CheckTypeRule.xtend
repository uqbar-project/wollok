package org.uqbar.project.wollok.typesystem.substitutions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeExpectationFailedException
import org.uqbar.project.wollok.typesystem.TypeSystemException

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * t(a) = t(b)
 * 
 * @author jfernandes
 */
class CheckTypeRule extends TypeRule {
	EqualityNode a
	EqualityNode b
	TypeCheck check
	
	new(EObject source, EObject a, TypeCheck check, EObject b) {
		super(source)
		this.a = new UnknownNode(a)
		this.check = check
		this.b = new UnknownNode(b)
	}

	override resolve(SubstitutionBasedTypeSystem system) {
		// force evaluating both sides
		val aR = a.tryToResolve(system, this)
		val bR = b.tryToResolve(system, this)
		
		aR || bR
	}

	override typeOf(EObject object) {
		if (a.isNonTerminalFor(object)) b.type
		else if (b.isNonTerminalFor(object)) a.type
		else null
	}

	override check() {
		try {
			if (a.type != null && b.type != null) // mmmm...
				check.check(a.type, b.type)
		}
		catch (TypeExpectationFailedException e) {
			e.model = source
			throw e
		}
	}

	def changeNode(EqualityNode node, EqualityNode newNode) {
		if (a == node) a = newNode
		else if (b == node) b = newNode
		else throw new TypeSystemException("Cannot substitute unknown node!")
	}

	// object

	override ruleStateLeftPart() { '''«a» «check.operandString» «b» ''' }
	override ruleStateRightPart() { "(" + source.lineNumber + ": " + source.formattedSourceCode + ")" }

	override equals(Object obj) {
		if (obj instanceof CheckTypeRule)
			a == obj.a && b == obj.b
		else 
			false
	}

	override hashCode() { a.hashCode / b.hashCode }

}