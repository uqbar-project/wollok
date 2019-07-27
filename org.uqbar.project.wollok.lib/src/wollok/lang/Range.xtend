package wollok.lang

import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * 
 * @author jfernandes
 * @author dodain
 * 
 */
class Range extends AbstractJavaWrapper<IntegerRange> {
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}
	
	def void forEach(WollokObject proc) {
		proc.checkNotNull("forEach")
		val c = (proc.getNativeObject(CLOSURE) as Closure)
		getWrapped.forEach[e| c.doApply(e.javaToWollok) ]
	}
	
	override getWrapped() {
		if (wrapped === null) {
			val start = "start".solve
			val end = "end".solve
			val step = "step".solve
			wrapped = new IntegerRange(start, end, step)
		}
		wrapped
	}
	
	def anyOne() {
		getWrapped.toList.random
	}
}