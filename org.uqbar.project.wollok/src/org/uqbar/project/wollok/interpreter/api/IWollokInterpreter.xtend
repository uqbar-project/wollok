package org.uqbar.project.wollok.interpreter.api

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.context.EvaluationContext

interface IWollokInterpreter {
	def Object eval(EObject e)
	def Object performOnStack(EObject executable, EvaluationContext newContext, ()=>Object something)
	def Object addGlobalReference(String name, Object value)
}