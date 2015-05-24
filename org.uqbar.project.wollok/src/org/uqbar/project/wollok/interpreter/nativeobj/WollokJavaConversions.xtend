package org.uqbar.project.wollok.interpreter.nativeobj

import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

/**
 * Holds common extensions for Wollok to Java and Java to Wollok conversions.
 * 
 * @author jfernandes
 */
class WollokJavaConversions {
	
	def static <Input> Procedure1<Input> asProc(WollokClosure proc) { [proc.apply(it as Input)] }
	
	def static <Input, Output> asFun(WollokClosure closure) { [closure.apply(it as Input) as Output] }
	
}