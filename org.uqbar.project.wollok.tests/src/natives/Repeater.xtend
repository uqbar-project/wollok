package natives

import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * @author jfernandes
 */
class Repeater {
	
	def ntimes(Integer n, WollokObject clos) {
		val closure = clos.asClosure
		closure.doApply()
	}
	
}