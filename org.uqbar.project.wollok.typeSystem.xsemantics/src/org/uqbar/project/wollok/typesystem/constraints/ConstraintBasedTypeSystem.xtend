package org.uqbar.project.wollok.typesystem.constraints

import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WBooleanLiteral
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNumberLiteral
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WStringLiteral

import static org.uqbar.project.wollok.typesystem.WollokType.*
import static org.uqbar.project.wollok.typesystem.constraints.TypeVariablesFactory.*

/**
 * @author npasserini
 */
class ConstraintBasedTypeSystem implements TypeSystem {
	val Map<EObject, TypeVariable> typeVariables = newHashMap
	
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
		println(node)
	}

	def dispatch void generateVariables(WNumberLiteral num) {
		typeVariables.put(num, sealed(WInt))
	}

	def dispatch void generateVariables(WStringLiteral string) {
		typeVariables.put(string, sealed(WString))
	}

	def dispatch void generateVariables(WBooleanLiteral bool) {
		typeVariables.put(bool, sealed(WBoolean))
	}

	// ************************************************************************
	// ** Other (TBD)
	// ************************************************************************
	override inferTypes() {
	}

	override type(EObject obj) {
		val typeVar = typeVariables.get(obj)
		if(typeVar == null) throw new RuntimeException("I don't have type information for " + obj)
		typeVar.type
	}

	override issues(EObject obj) {
		#[]
	}
	
	override queryMessageTypeForMethod(WMethodDeclaration declaration) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}
