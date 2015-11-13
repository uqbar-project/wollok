package org.uqbar.project.wollok.interpreter.api

import java.io.Serializable
import org.eclipse.emf.ecore.EObject

/**
 * Abstraction over an object that knows 
 * how to evaluate a semantic model object from your
 * DSL.
 * For example an Expression, or any object.
 * 
 * The XInterpreter will ask this object to evaluate
 * all the objects.
 * 
 * It's basically what you must implement when creating your
 * own interpreter.
 * 
 * @author jfernandes
 */
interface XInterpreterEvaluator extends Serializable {
	
	def Object evaluate(EObject o)

	def (Object,()=>Object)=>Object resolveBinaryOperation(String operator)
	
}