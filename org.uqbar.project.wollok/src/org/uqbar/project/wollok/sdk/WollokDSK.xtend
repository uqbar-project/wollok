package org.uqbar.project.wollok.sdk

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.core.WollokObject
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Contains class names for Wollok core SDK.
 * The interpreter is now instantiating this classes
 * for example for list literals or strings, booleans, etc.
 * But they are in another project, and the interpreter doesn't depend on it
 * (there's a circularity there), so we need to make refereces using the FQN
 * String.
 * 
 * This just defines the strings in a single place for easing maintenance.
 * 
 * import static extension org.uqbar.project.wollok.sdk.WollokDSK.*
 * 
 * @author jfernandes
 */
//TODO: fix typo
class WollokDSK {
	
	public static val OBJECT = "wollok.lang.Object"
	public static val VOID = "wollok.lang.void"

	public static val STRING = "wollok.lang.String"
	public static val INTEGER = "wollok.lang.Integer"
	public static val DOUBLE = "wollok.lang.Double"
	public static val BOOLEAN = "wollok.lang.Boolean"

	public static val COLLECTION = "wollok.lang.Collection"
	public static val LIST = "wollok.lang.List"
	public static val SET = "wollok.lang.Set"
	
	public static val CLOSURE = "wollok.lang.Closure"
	
	public static val EXCEPTION = "wollok.lang.Exception"
	
	public static val MESSAGE_NOT_UNDERSTOOD_EXCEPTION = "wollok.lang.MessageNotUnderstoodException"
	
	def static WollokObject getVoid(WollokInterpreter i, EObject context) {
		(i.evaluator as WollokInterpreterEvaluator).getWKObject(VOID, context)
	}
	
	def static isBasicType(WollokObject it) {
		val fqn = behavior.fqn
		fqn == INTEGER || fqn == DOUBLE || fqn == STRING || fqn == BOOLEAN
	}
	
}