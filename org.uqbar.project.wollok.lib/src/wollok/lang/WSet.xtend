package wollok.lang

import java.util.Set
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set>  implements JavaWrapper<Set> {
	
	new() {
		wrapped = newHashSet
	}
	
	def anyOne() { wrapped.head }
	
}