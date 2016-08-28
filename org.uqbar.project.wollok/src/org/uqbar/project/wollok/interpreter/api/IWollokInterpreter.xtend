package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * This is the interpreter interface exposed
 * to XInterpreterEvaluator implementations
 * so that they can access the interpreter to evaluate
 * inner objects.
 * 
 * It is separated from XInterpreter to avoid confusion
 * between the clients that want to evaluate a program and the interpreter
 * implementation
 * 
 * @author jfernandes
 */
// this should be generalized (remove WollokObject type) and be moved up to xinterpreter
interface IWollokInterpreter {
	
	def WollokObject eval(EObject e)
	
	def WollokObject performOnStack(EObject executable, EvaluationContext<WollokObject> newContext, ()=>WollokObject something)
	
	def WollokObject addGlobalReference(String name, WollokObject value)
	def void removeGlobalReference(String name)
	
	def EvaluationContext<WollokObject> getCurrentContext()

}