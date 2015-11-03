package org.uqbar.project.wollok.interpreter.natives

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WNamedObject

/**
 * Strategy for instantiating the corresponding
 * java native part of a wollok native object.
 * 
 * It is interesting to decouple this from the interpreter
 * because we could have different strategies like using 
 * wollok annotations or differente conventions.
 * 
 * @author jfernandes
 */
interface NativeObjectFactory {
	
	def Object createNativeObject(WClass it, WollokObject obj, WollokInterpreter interpreter)
	
	def Object createNativeObject(WNamedObject it, WollokObject obj, WollokInterpreter interpreter)
	
}