package wollok.lang

import java.time.LocalDate
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

/**
 * Native implementation of the date wollok class
 * 
 * @author dodain
 */
class WDate {

	LocalDate wrapped 
	
	/**
	 * Constructores
	 */
	new() {
		wrapped = LocalDate.now()
	}

	private new(LocalDate date) {
		wrapped = date
	}
	
	/** Fin constructores */

	def void initialize(int day, int month, int year) {
		wrapped = LocalDate.of(year, month, day)
	}

	def plusDays(int days) { 
		val dateAdded = wrapped.plusDays(days)
		new WDate(dateAdded)
	}

	def plusMonths(int months) {
		val dateAdded = wrapped.plusMonths(months)
		new WDate(dateAdded)
	}

	def plusYears(int years) { 
		val dateAdded = wrapped.plusYears(years) 
		new WDate(dateAdded)
	}

	def isLeapYear() { wrapped.isLeapYear }
	
	def wollokToString() { wrapped.toString }
	
	def day() { wrapped.dayOfMonth }
	
	def month() { wrapped.month.value }
	
	def year() { wrapped.year }

	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped?.equals(this.wrapped))
	}

	@NativeMessage("-")
	def minus(WDate aDate) { 
		val difference = (aDate.wrapped.toEpochDay - wrapped.toEpochDay) as int
		Math.abs(difference)
	}
	
	def minusDays(int days) {
		val dateSubtracted = wrapped.minusDays(days)
		new WDate(dateSubtracted) 
	}
	
	def minusMonths(int months) { 
		val dateSubtracted = wrapped.minusMonths(months)
		new WDate(dateSubtracted)
	}
	
	def minusYears(int years) { 
		val dateSubtracted = wrapped.minusYears(years)
		new WDate(dateSubtracted)
	}
	
	def dayOfWeek() { wrapped.dayOfWeek.value }
	
	@NativeMessage("<")
	def lessThan(WDate aDate) {
		compareTo(aDate) < 0
	}
	
	@NativeMessage(">")
	def greaterThan(WDate aDate) { compareTo(aDate) > 0 }
	 
	def compareTo(WDate aDate) { wrapped.compareTo(aDate.wrapped) }
	
	override toString() { wrapped.toString() }

	override hashCode() { wrapped.hashCode }
	
	def toSmartString(Object alreadyShown) { wollokToString }
	
	def convertToWString(WollokObject it) { call("toString") as WollokObject }

	@NativeMessage("==")
	def wollokIdentityEquals(WollokObject other) {
		val wDate = other.getNativeObject(WDate) as WDate
		wDate != null && wrapped == wDate.wrapped
	}
	
	def asWString(WollokObject it) { 
		val wDate = it.getNativeObject(WDate) as WDate
		if (wDate == null) throw new WollokRuntimeException("Expecting object to be a date: " + it)
		wDate
	}

	def static getEvaluator() { (WollokInterpreter.getInstance.evaluator as WollokInterpreterEvaluator) }
		
}
