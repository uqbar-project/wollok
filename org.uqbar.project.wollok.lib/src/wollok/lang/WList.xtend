package wollok.lang

import java.util.List
import java.util.Comparator
import java.util.Collection
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*

/**
 * Native part of the wollok.lang.List class
 * 
 * @author jfernandes
 */
class WList extends WCollection<List<WollokObject>> implements JavaWrapper<List<WollokObject>> {

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
		//return wollokInstance
	}
	
	override protected def verifyWollokElementsContained(Collection list, Collection list2) {
		val size = list2.size - 1
		list.empty ||
		(0..size).forall [ i |
			val obj1 = list2.get(i) as WollokObject
			val obj2 = list.get(i) as WollokObject
			obj1.wollokEquals(obj2)
		]
	}
}