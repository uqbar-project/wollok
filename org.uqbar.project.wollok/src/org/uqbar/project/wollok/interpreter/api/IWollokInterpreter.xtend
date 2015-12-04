package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.context.EvaluationContext
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * 
 * @author jfernandes
 */
interface IWollokInterpreter {
	def WollokObject eval(EObject e)
	def WollokObject performOnStack(EObject executable, EvaluationContext newContext, ()=>WollokObject something)
	def WollokObject addGlobalReference(String name, WollokObject value)
	def EvaluationContext getCurrentContext()
}