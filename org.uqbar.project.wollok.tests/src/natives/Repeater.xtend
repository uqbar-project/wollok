package natives

import java.math.BigDecimal
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * @author jfernandes
 */
class Repeater {
	
	def ntimes(BigDecimal n, WollokObject clos) {
		n.coerceToInteger
		val closure = clos.asClosure
		closure.doApply()
	}
	
}