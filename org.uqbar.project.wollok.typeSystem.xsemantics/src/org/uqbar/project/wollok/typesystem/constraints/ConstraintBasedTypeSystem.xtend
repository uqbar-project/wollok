package org.uqbar.project.wollok.typesystem.constraints

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokClassFinder
import org.uqbar.project.wollok.typesystem.ClassBasedWollokType
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WIfExpression
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WStringLiteral
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.sdk.WollokDSK.*

/**
 * @author npasserini
 */
class ConstraintBasedTypeSystem implements TypeSystem {
	@Inject WollokClassFinder finder
	val extension TypeVariablesRegistry registry = new TypeVariablesRegistry(this)
	
	override def name() { "Constraints-based" }
	
	override validate(WFile file, WollokDslValidator validator) {
		println("Validation with " + class.simpleName + ": " + file.eResource.URI.lastSegment)
		this.analyse(file)
		this.inferTypes
		// TODO: report errors !
	}

	// ************************************************************************
	// ** Analysis
	// ************************************************************************
	
	override analyse(EObject p) {
		p.eContents.forEach[generateVariables]
	}
	
	def dispatch void generateVariables(WProgram p) {
		p.elements.forEach[generateVariables]
	}
	
//	def dispatch void generateVariables(WLibrary p) {
//		p.elements.forEach[generateVariables]
//	}

	def dispatch void generateVariables(EObject node) {
		println('''WARNING: Not generating constraints for: «node»''')
	}

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
		}
		else {
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

	// ************************************************************************
	// ** Other (TBD)
	// ************************************************************************
	
	override inferTypes() {
		new PropagateMinimalTypes(registry).run()
	}

	override type(EObject obj) {
		obj.tvar.type
	}

	override issues(EObject obj) {
		#[]
	}
	
	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	protected def ClassBasedWollokType classType(EObject model, String className) {
		val clazz = finder.getCachedClass(model, className)
		// REVIEWME: should we have a cache ?
		new ClassBasedWollokType(clazz, this)
	}

}
