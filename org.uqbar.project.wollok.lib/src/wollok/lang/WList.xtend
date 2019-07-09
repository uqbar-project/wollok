package wollok.lang

import java.math.BigDecimal
import java.util.Collection
import java.util.Comparator
import java.util.List
import java.util.TreeSet
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

	new(WollokObject o) {
		wrapped = newArrayList
	}
	
	def get(BigDecimal index) {
		val convertedIndex = index.coerceToPositiveInteger
		wrapped.get(convertedIndex)
	}

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
	}

	def max() {
		val result = new TreeSet(new WollokObjectComparator)
		result.addAll(wrapped) 
		return result.last
	}
	
	override protected def verifyWollokElementsContained(Collection<WollokObject> list, Collection<WollokObject> list2) {
		val size = list2.size - 1
		list.empty ||
		(0..size).forall [ i |
			val obj1 = list2.get(i) as WollokObject
			val obj2 = list.get(i) as WollokObject
			obj1.wollokEquals(obj2)
		]
	}
}
