package wollok.lang

import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

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

	def void initialize(int day, int month, int year) {
		wrapped = LocalDate.of(year, month, day)
	}

	def plusDays(int days) { 
		wrapped.plusDays(days)
	}

	def plusMonths(int months) {
		wrapped.plusMonths(months)
	}

	def plusYears(int years) { 
		wrapped.plusYears(years) 
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
		wrapped.minusDays(days)
	}
	
	def minusMonths(int months) { 
		wrapped.minusMonths(months)
	}
	
	def minusYears(int years) { 
		wrapped.minusYears(years)
	}
	
	def dayOfWeek() { wrapped.dayOfWeek.value }
	
	@NativeMessage("<")
	def lessThan(WDate aDate) {
		compareTo(aDate) < 0
	}
	
	@NativeMessage(">")
	def greaterThan(WDate aDate) { compareTo(aDate) > 0 }
	 
	def compareTo(WDate aDate) { wrapped.compareTo(aDate.wrapped) }
	
	override toString() {
		//val formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy") 
		//"Date[" + wrapped.format(formatter) + "]"
		"Date[" + wrapped.toString + "]"
	}

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
