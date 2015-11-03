package wollok.lang

import java.util.List
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

/**
 * Native part of the wollok.lang.List class
 * 
 * @author jfernandes
 */
class WList extends WCollection<List> implements JavaWrapper<List> {
	
	new() {
		wrapped = newArrayList
	}
	
	def get(int index) { wrapped.get(index) }
	
}