package wollok.lang

import java.util.Set

/**
 * @author jfernandes
 */
class WSet extends WCollection<Set> {
	
	new() {
		wrapped = newHashSet
	}
	
	def anyOne() { wrapped.head }
	
}