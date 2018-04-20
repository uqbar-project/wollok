package wollok.lang

import java.math.BigDecimal
import java.time.LocalDate
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
/**
 * Native implementation of the date wollok class
 * 
 * @author dodain
 */
class WDate extends AbstractJavaWrapper<LocalDate> {

	/**
	 * Constructores
	 */
	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
		wrapped = LocalDate.now()
	}
	 
	/** Fin constructores */

	def void initialize(BigDecimal day, BigDecimal month, BigDecimal year) {
		wrapped = LocalDate.of(year.coerceToInteger, month.coerceToInteger, day.coerceToInteger)
	}

	def plusDays(BigDecimal days) {
		days.checkNotNull("plusDays") 
		wrapped.plusDays(days.coerceToInteger)
	}

	def plusMonths(BigDecimal months) {
		months.checkNotNull("plusMonths")
		wrapped.plusMonths(months.coerceToInteger)
	}

	def plusYears(BigDecimal years) {
		years.checkNotNull("plusYears") 
		wrapped.plusYears(years.coerceToInteger) 
	}

	def isLeapYear() { wrapped.isLeapYear }
	
	def wollokToString() { wrapped.toString }
	
	def day() { wrapped.dayOfMonth }
	
	def month() { wrapped.month.value }
	
	def year() { wrapped.year }

	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped?.equals(this.wrapped))
	}

	@NativeMessage("-")
	def minus(LocalDate aDate) { 
		wrapped.toEpochDay - aDate.toEpochDay
	}
	
	def minusDays(BigDecimal days) {
		days.checkNotNull("minusDays") 
		wrapped.minusDays(days.coerceToInteger)
	}
	
	def minusMonths(BigDecimal months) { 
		months.checkNotNull("minusMonths") 
		wrapped.minusMonths(months.coerceToInteger)
	}
	
	def minusYears(BigDecimal years) {
		years.checkNotNull("minusYears") 
		wrapped.minusYears(years.coerceToInteger)
	}
	
	def dayOfWeek() { wrapped.dayOfWeek.value }
	
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
		wrapped.compareTo(aDate)
	}
	
	override hashCode() { 
		wrapped.hashCode
	}
	
	override toString() {
		"Date[" + wrapped.toString + "]"
	}

	@NativeMessage("==")
	def wollokIdentityEquals(WollokObject other) {
		val wDate = other.getNativeObject(WDate) as WDate
		wDate !== null && wrapped == wDate.wrapped
	}
	
	def asWString(WollokObject it) { 
		val wDate = it.getNativeObject(WDate) as WDate
		// TODO: i18n
		if (wDate === null) throw new WollokRuntimeException("Expecting object to be a date: " + it)
		wDate
	}

}
