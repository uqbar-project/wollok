package wollok.lang

import java.math.BigDecimal
import java.time.LocalDate
import java.util.Comparator
import java.util.Map
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension wollok.lang.WollokObjectComparator.*

/**
 * Definition for performance
 */
class WollokObjectComparator implements Comparator<WollokObject> {
	Map<String, Comparator<WollokObject>> comparisonsStrategy = newHashMap(
		STRING  -> new WollokStringComparator,
		NUMBER  -> new WollokNumberComparator,
		DATE    -> new WollokDateComparator,
		BOOLEAN -> new WollokBooleanComparator
	)
	
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess
	
	override compare(WollokObject o1, WollokObject o2) {
		try {
			if (o1 === o2) return 0
			if (o1 === null && o2 === null) return 0
			if (o1 === null && o2 !== null) return -1
			if (o1 !== null && o2 === null) return 1
			val comparator = comparisonsStrategy.get(o1.kind.fqn) ?: new WollokObjectEqualsComparator		
			return comparator.compare(o1, o2)
		} catch (RuntimeException e) {
			return o1.defaultOrderingCompare(o2)
		}
	}
	
	/**
	 * So, we tried everything and the two objects are not comparable, so we'll impose just any arbitrary but consistent order.
	 * The objective of this ordering is to guarantee that, in a set of non-comparable objects (e.g. objects of different kind or objects 
	 * not comparable by nature such as lists or sets), if you later add an object that is comparable to any one of the already existing ones,
	 * the new object will be compared to the right objects.
	 * 
	 * This is achieved by the concatenation of:
	 * (a) the object's kind's fully qualified name (to group objects of the same kind),
	 * (b) the object's to string (that means that the toString of non comparable objects should be consistent with equality)
	 * (c) the object's hashCode (just to ensure that any two objects that arrive here are considered different from each other).
	 */
	static def defaultOrderingCompare(WollokObject o1, WollokObject o2) {
		return o1.defaultOrderingKey.compareTo(o2.defaultOrderingKey)
	}

	static def defaultOrderingKey(WollokObject object) {
		object.hashCode
	}
}

/**
 * Original definition
 */
class WollokObjectEqualsComparator implements Comparator<WollokObject> {
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess

	override compare(WollokObject o1, WollokObject o2) {
		if (o1.hasEqualsMethod && o1.wollokEqualsMethod(o2)) {
			return 0
		} 
		if (o2.hasEqualsMethod && o2.wollokEqualsMethod(o1)) {
			return 0 
		}
		if (o1.hasGreaterThanMethod) {
			return if (o1.wollokGreaterThan(o2)) 1 else -1
		}
		if (o2.hasGreaterThanMethod) {
			return if (o2.wollokGreaterThan(o1)) -1 else 1
		}

		return o1.defaultOrderingCompare(o2)
	}
}

abstract class WollokNativeComparator<T extends Comparable<T>> implements Comparator<WollokObject> {
	override compare(WollokObject o1, WollokObject o2) {
		if (o1 === null && o2 === null) return 0
		if (o1 === null || o2 === null) return 1
		val data1 = o1.getData
		val data2 = o2.getData
		return data1.compareTo(data2) 
	}
	
	def getData(Object o) {
		(o as WollokObject).nativeObject.wrapped as T
	}
	
	abstract def JavaWrapper<T> nativeObject(WollokObject o)
}

class WollokStringComparator extends WollokNativeComparator<String> {
	override nativeObject(WollokObject o) {
		o.getNativeObject(STRING) as JavaWrapper<String>
	}
}

class WollokNumberComparator extends WollokNativeComparator<BigDecimal> {
	override nativeObject(WollokObject o) {
		o.getNativeObject(NUMBER) as JavaWrapper<BigDecimal>
	}
}

class WollokBooleanComparator extends WollokNativeComparator<Boolean> {
	override nativeObject(WollokObject o) {
		o.getNativeObject(BOOLEAN) as JavaWrapper<Boolean>
	}
}

class WollokDateComparator implements Comparator<WollokObject> {
	
	override compare(WollokObject o1, WollokObject o2) {
		if (o1 === null && o2 === null) return 0
		if (o1 === null || o2 === null) return 1
		val date1 = ((o1 as WollokObject).getNativeObject(DATE) as JavaWrapper<LocalDate>).wrapped
		val date2 = ((o2 as WollokObject).getNativeObject(DATE) as JavaWrapper<LocalDate>).wrapped
		return date1.compareTo(date2) 
	}
	
}
