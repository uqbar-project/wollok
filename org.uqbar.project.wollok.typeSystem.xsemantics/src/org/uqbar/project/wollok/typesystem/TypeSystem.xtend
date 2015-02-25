package org.uqbar.project.wollok.typesystem

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.semantics.WollokType
import org.uqbar.project.wollok.typesystem.bindings.TypeExpectationFailedException
import org.uqbar.project.wollok.wollokDsl.WProgram

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
}