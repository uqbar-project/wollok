package org.uqbar.project.wollok.typesystem

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.validation.ConfigurableDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * An engine that performs type inference and type checks.
 * Common interface for the different implementations.
 * To be able to compare them with the same tests cases.
 * 
 * @author jfernandes
 */
interface TypeSystem {

	def String name()

	/**
	 * Allow for type system initialisation. 
	 * @param file One of the files to be analysed. 
	 * 	      A typing session should allow for more than one file, but 
	 *        a first file/resource is sometimes required for some initialization tasks, 
	 * 	      for example to access Wollok core manifests.
	 */
	def void initialize(EObject program)

	// This method is kind of a hack to use the type systems from the validator
	// it is supposed to analyze (#analyse, #inferTypes) the program and report any error to the validator
	def void validate(WFile file, ConfigurableDslValidator validator)

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
	 * # 3a: 
	 * Now we can report errors
	 */
	def void reportErrors(WFile file, ConfigurableDslValidator validator)

	/**
	 * # 3b:
	 * Or you can perform queries for types.
	 */
	def WollokType type(EObject obj)

	def Iterable<TypeExpectationFailedException> issues(EObject obj)

	// this was brought up from xsemantics impl/
	// maybe it should be something particular to xsemantincs	
	def MessageType queryMessageTypeForMethod(WMethodDeclaration declaration)

}