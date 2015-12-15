package org.uqbar.project.wollok.typesystem

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.typesystem.MessageType

/**
 * An engine that performs type inference and type checks.
 * Common interface for the different implementations.
 * To be able to compare them with the same tests cases.
 * 
 * @author jfernandes
 */
interface TypeSystem {
	
	/**
	 * # 1: First step
	 * Builds any needed graph or rules based on the program.
	 */
	def void analyse(EObject root)
	
	/**
	 * # 2: 
	 * Second step. Goes through all the bindings and tries to infer types.
	 */
	def void inferTypes()
	
	/**
	 * # 3:
	 * Then you can perform queries for types.
	 */
	def WollokType type(EObject obj)
	def Iterable<TypeExpectationFailedException> issues(EObject obj)

	// this was bringed up from xsemantics impl/
	// maybe it should be something particular to xsemantincs	
	def MessageType queryMessageTypeForMethod(WMethodDeclaration declaration)
	
}