package wollok.lang

import java.util.Comparator
import java.util.List
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * Native part of the wollok.lang.List class
 * 
 * @author jfernandes
 */
class WList extends WCollection<List> implements JavaWrapper<List> {

 	val WollokObject wollokInstance
 
	new(WollokObject o) {
		wollokInstance = o
		wrapped = newArrayList
	}
	
	def get(int index) { wrapped.get(index) }

	def sortBy(WollokObject predicate) {
		val closure = predicate.asClosure
		/*Convert the closure into a comparator to use the standard sort*/
		val comparator = new Comparator {
			override def compare(Object a, Object b) {
				if(closure.doApply(a as WollokObject,b as WollokObject).isTrue)
					-1
				else
					1
			} 
		}
		wrapped = wrapped.sortWith(comparator)
		return wollokInstance
	}	
}