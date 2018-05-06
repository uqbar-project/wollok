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
	
	// ************************************************************************
	// ** SDK Classes
	// ************************************************************************

	public static val OBJECT = "wollok.lang.Object"
	public static val VOID = "wollok.lang.void"

	public static val STRING = "wollok.lang.String"
	public static val NUMBER = "wollok.lang.Number"
	public static val BOOLEAN = "wollok.lang.Boolean"
	public static val DATE = "wollok.lang.Date"
	public static val PAIR = "wollok.lang.Pair"

	public static val COLLECTION = "wollok.lang.Collection"
	public static val LIST = "wollok.lang.List"
	public static val SET = "wollok.lang.Set"
	public static val DICTIONARY = "wollok.lang.Dictionary"
	public static val RANGE = "wollok.lang.Range"
	
	public static val CLOSURE = "wollok.lang.Closure"
	
	public static val EXCEPTION = "wollok.lang.Exception"
	public static val STACK_TRACE_ELEMENT = "wollok.lang.StackTraceElement"
	public static val INSTANCE_VARIABLE_MIRROR = "wollok.mirror.InstanceVariableMirror"
	
	public static val POSITION = "wollok.lib.Position"
	public static val ASSERTION_EXCEPTION_FQN = "wollok.lib.AssertionException"
	public static val STRING_PRINTER = "wollok.lib.StringPrinter"
	
	public static val MESSAGE_NOT_UNDERSTOOD_EXCEPTION = "wollok.lang.MessageNotUnderstoodException"
	public static val STACK_OVERFLOW_EXCEPTION = "wollok.lang.StackOverflowException"

	// ************************************************************************
	// ** SDK Objects
	// ************************************************************************

	public static val CONSOLE = "wollok.lib.console"
	public static val ASSERT = "wollok.lib.assert"
	
	def static WollokObject getVoid(WollokInterpreter i, EObject context) {
		(i.evaluator as WollokInterpreterEvaluator).getWKObject(VOID, context)
	}
	
	def static isBasicType(WollokObject it) {
		val fqn = behavior.fqn
		val bt = fqn == NUMBER || fqn == STRING || fqn == BOOLEAN
//		println("[VM] \t\tis " + fqn + " basic type " + bt)
		bt
	}
	
}