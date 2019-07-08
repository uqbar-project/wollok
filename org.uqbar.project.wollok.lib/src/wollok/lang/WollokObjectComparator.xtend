package wollok.lang

import java.math.BigDecimal
import java.time.LocalDate
import java.util.Comparator
import java.util.Map
import org.uqbar.project.wollok.interpreter.api.WollokInterpreterAccess
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.JavaWrapper

import static org.uqbar.project.wollok.sdk.WollokDSK.*

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

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
			if (o1 === null && o2 === null) return 0
			if (o1 === null && o2 !== null) return -1
			if (o1 !== null && o2 === null) return 1
			val comparator = comparisonsStrategy.get(o1.kind.fqn) ?: new WollokObjectEqualsComparator		
			return comparator.compare(o1, o2)
		} catch (RuntimeException e) {
			return o1.hashCode.compareTo(o2.hashCode)
		}
	}
	
}

/**
 * Original definition
 */
class WollokObjectEqualsComparator implements Comparator<WollokObject> {
	protected extension WollokInterpreterAccess = new WollokInterpreterAccess

	override compare(WollokObject o1, WollokObject o2) {
		if (o1.hasEqualsMethod && o1.kind.name.equals(o2.kind.name)) {
			return if (o1.wollokEquals(o2)) 0 else 1 // o1.compareGreaterThan(o2)
		}
		// default case
		return o1.hashCode.compareTo(o2.hashCode)
	}

	def compareGreaterThan(WollokObject o1, WollokObject o2) {
		if (o1.hasGreaterThanMethod) {
			 if (o1.wollokGreaterThan(o2)) 1 else -1
		} else 1
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
