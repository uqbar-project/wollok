package wollok.lang

import java.time.LocalDate
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

	def plusDays(int days) { wrapped.plusDays(days) }

	def plusMonths(int months) { wrapped.plusMonths(months) }

	def plusYears(int years) { wrapped.plusDays(years) }

	def isLeapYear() { wrapped.isLeapYear }
	
	def wollokToString() { wrapped.toString }
	
	def day() { wrapped.dayOfMonth }
	
	def month() { wrapped.month }
	
	def year() { wrapped.year }

	@NativeMessage("equals")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped?.equals(this.wrapped))
	}

	def minus(WDate aDate) { aDate.wrapped.toEpochDay - wrapped.toEpochDay }
	
	def minusDays(int days) {
		val minusDays = wrapped.minusDays(days)
		println(minusDays)
		val result = new WDate(minusDays)
		println(result)
		result
	}
	
	def minusMonths(int months) { wrapped.minusMonths(months) }
	
	def minusYears(int years) { wrapped.minusYears(years) }
	
	def between(WDate startDate, WDate endDate) { this.lessThan(startDate) && this.greaterThan(endDate) }
	
	def dayOfWeek() { wrapped.dayOfWeek }
	
	@NativeMessage("<")
	def lessThan(WDate aDate) { println(aDate) compareTo(aDate) == -1 }
	
	@NativeMessage(">")
	def greaterThan(WDate aDate) { compareTo(aDate) == 1 }
	 
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
	
}
