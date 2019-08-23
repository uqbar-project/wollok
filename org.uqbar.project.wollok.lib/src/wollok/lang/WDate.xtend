package wollok.lang

import java.math.BigDecimal
import java.time.LocalDate
import java.time.chrono.IsoChronology
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.format.FormatStyle
import java.util.Locale
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import static extension org.uqbar.project.wollok.utils.WollokObjectUtils.*

/**
 * Native implementation of the date wollok class
 * Refactor 2.0 => using Wollok properties and define Date as immutable
 * 
 * @author dodain
 */
class WDate extends AbstractJavaWrapper<LocalDate> {
	
	var public static FORMATTER = DateTimeFormatter.ofPattern(WDate.getLocalizedFormat(Locale.^default))

	new(WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter)
	}

	def void initialize() {
		this.setWrapped(LocalDate.now)
	}
	
	override void setWrapped(LocalDate originalDate) {
		val day = "day".solveOrAssign(originalDate.dayOfMonth)
		val month = "month".solveOrAssign(originalDate.monthValue)
		val year = "year".solveOrAssign(originalDate.year)
		wrapped = LocalDate.of(year, month, day)
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
	
	@NativeMessage("==")
	def wollokEquals(WollokObject other) {
		other.hasNativeType(this.class.name) && (other.getNativeObject(this.class).wrapped.equals(this.wrapped))
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
	
	def internalDayOfWeek() { wrapped.dayOfWeek.value }
	
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
	
	def shortDescription() {
		getWrapped.format(FORMATTER)
	}
	
	def static getLocalizedFormat(Locale locale) {
		return DateTimeFormatterBuilder
			.getLocalizedDateTimePattern(FormatStyle.SHORT, null, IsoChronology.INSTANCE, locale)
			.replaceFirst("/yy$", "/yyyy")
	}
}
