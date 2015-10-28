package org.uqbar.project.wollok.interpreter.nativeobj

import org.uqbar.project.wollok.interpreter.core.WollokClosure
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * Holds common extensions for Wollok to Java and Java to Wollok conversions.
 * 
 * @author jfernandes
 */
class WollokJavaConversions {
	
	def static <Input> Procedure1<Input> asProc(WollokClosure proc) { [proc.apply(it as Input)] }
	
	def static <Input, Output> asFun(WollokClosure closure) { [closure.apply(it as Input) as Output] }
	
	def static asInteger(WollokObject it) { ((it as WollokObject).getNativeObject("wollok.lang.WInteger") as JavaWrapper<Integer>).wrapped }
	
}