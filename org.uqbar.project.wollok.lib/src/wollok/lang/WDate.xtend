package wollok.lang

import java.math.BigDecimal
import java.time.LocalDate
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

/**
 * Native implementation of the date wollok class
 * Refactor 2.0 => using Wollok properties and define Date as immutable
 * 
 * @author dodain
 */
class WDate extends AbstractJavaWrapper<LocalDate> {

	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}

	override getWrapped() {
		if (wrapped === null) {
			val today = LocalDate.now
			val day = "day".solveOr(today.dayOfMonth)
			val month = "month".solveOr(today.monthValue)
			val year = "year".solveOr(today.year)
			wrapped = LocalDate.of(year, month, day)
		}
		wrapped
	}
	
	def plusDays(BigDecimal days) {
		days.checkNotNull("plusDays") 
		getWrapped.plusDays(days.coerceToInteger)
	}

	def plusMonths(BigDecimal months) {
		months.checkNotNull("plusMonths")
		getWrapped.plusMonths(months.coerceToInteger)
	}

	def plusYears(BigDecimal years) {
		years.checkNotNull("plusYears") 
		getWrapped.plusYears(years.coerceToInteger) 
	}

	def isLeapYear() { getWrapped.isLeapYear }
	
	def wollokToString() { getWrapped.toString }
	
	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).getWrapped.equals(this.getWrapped))
	}

	@NativeMessage("-")
	def minus(LocalDate aDate) { 
		getWrapped.toEpochDay - aDate.toEpochDay
	}
	
	def minusDays(BigDecimal days) {
		days.checkNotNull("minusDays") 
		getWrapped.minusDays(days.coerceToInteger)
	}
	
	def minusMonths(BigDecimal months) { 
		months.checkNotNull("minusMonths") 
		getWrapped.minusMonths(months.coerceToInteger)
	}
	
	def minusYears(BigDecimal years) {
		years.checkNotNull("minusYears") 
		getWrapped.minusYears(years.coerceToInteger)
	}
	
	def dayOfWeek() { getWrapped.dayOfWeek.value }
	
	@NativeMessage("<")
	def lessThan(LocalDate aDate) {
		aDate.checkNotNull("<")
		compareTo(aDate) < 0
	}
	
	@NativeMessage(">")
	def greaterThan(LocalDate aDate) { 
		aDate.checkNotNull(">")
		compareTo(aDate) > 0
	}
	 
	def compareTo(LocalDate aDate) { 
		getWrapped.compareTo(aDate)
	}
	
	override hashCode() { 
		getWrapped.hashCode
	}
	
	override toString() {
		"Date[" + getWrapped.toString + "]"
	}

	@NativeMessage("==")
	def wollokIdentityEquals(WollokObject other) {
		val wDate = other.getNativeObject(WDate) as WDate
		wDate !== null && getWrapped == wDate.getWrapped
	}
	
}
