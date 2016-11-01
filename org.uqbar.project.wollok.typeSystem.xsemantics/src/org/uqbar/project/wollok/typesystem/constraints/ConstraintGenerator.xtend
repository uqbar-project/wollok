package org.uqbar.project.wollok.typesystem.constraints

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*

class ConstraintGenerator {
	extension ConstraintBasedTypeSystem typeSystem
	extension TypeVariablesRegistry registry	

	new(ConstraintBasedTypeSystem typeSystem) {
		this.typeSystem = typeSystem
		this.registry = typeSystem.registry
	}

	def dispatch void generateVariables(EObject node) {
		// Default case
		println('''WARNING: Not generating constraints for: «node»''')
	}

	def dispatch void generateVariables(WFile it) {
		 eContents.forEach[generateVariables]		
	}
	
	def dispatch void generateVariables(WProgram it) {
		elements.forEach[generateVariables]
	}

//	def dispatch void generateVariables(WLibrary p) {
//		p.elements.forEach[generateVariables]
//	}

	def dispatch void generateVariables(WNumberLiteral it) {
		newSealed(classType(INTEGER))
	}

	def dispatch void generateVariables(WStringLiteral it) {
		newSealed(classType(STRING))
	}

	def dispatch void generateVariables(WBooleanLiteral it) {
		newSealed(classType(BOOLEAN))
	}

	def dispatch void generateVariables(WAssignment it) {
		value.generateVariables
		feature.ref.tvar.beSupertypeOf(value.tvar)
	}

	def dispatch void generateVariables(WVariableReference it) {
		// Nothing to do
	}

	def dispatch void generateVariables(WIfExpression it) {
		condition.newSealed(classType(BOOLEAN))
		condition.generateVariables

		then.generateVariables

		if (getElse != null) {
			getElse.generateVariables

			// If there is a else branch, if can be an expression 
			// and has to be supertypeof both (else, then) branches
			it.newWithSubtype(then, getElse)
		} else {
			// If there is no else branch, if is NOT an expression, 
			// it is a (void) statement.
			beVoid
		}
	}

	def dispatch void generateVariables(WVariableDeclaration it) {
		val tvar = variable.newTypeVariable()

		if (right != null) {
			right.generateVariables
			right.tvar.beSubtypeOf(tvar)
		}
	}

}
