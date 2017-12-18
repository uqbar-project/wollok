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
		wrapped.plusDays(days.coerceToInteger)
	}

	def plusMonths(BigDecimal months) {
		wrapped.plusMonths(months.coerceToInteger)
	}

	def plusYears(BigDecimal years) { 
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
	def minus(WDate aDate) { 
		val difference = (aDate.wrapped.toEpochDay - wrapped.toEpochDay) as int
		Math.abs(difference)
	}
	
	def minusDays(BigDecimal days) {
		wrapped.minusDays(days.coerceToInteger)
	}
	
	def minusMonths(BigDecimal months) { 
		wrapped.minusMonths(months.coerceToInteger)
	}
	
	def minusYears(BigDecimal years) { 
		wrapped.minusYears(years.coerceToInteger)
	}
	
	def dayOfWeek() { wrapped.dayOfWeek.value }
	
	@NativeMessage("<")
	def lessThan(WDate aDate) {
		compareTo(aDate) < 0
	}
	
	@NativeMessage(">")
	def greaterThan(WDate aDate) { compareTo(aDate) > 0 }
	 
	def compareTo(WDate aDate) { wrapped.compareTo(aDate.wrapped) }
	
	override hashCode() { wrapped.hashCode }
	
//	def convertToWString(WollokObject it) { call("toString") as WollokObject }

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
