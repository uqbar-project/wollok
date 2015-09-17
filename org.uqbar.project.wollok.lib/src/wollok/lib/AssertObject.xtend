package wollok.lib

import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations
import java.text.MessageFormat
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * 
 * @author tesonep
 */
class AssertObject extends AbstractWollokDeclarativeNativeObject {

	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations

	@NativeMessage("that")
	def assertMethod(Boolean value) {
		if (!value)
			throw AssertionException.valueWasNotTrue
	}

	@NativeMessage("notThat")
	def assertFalse(Boolean value) {
		if (value)
			throw AssertionException.valueWasNotFalse
	}

	@NativeMessage("equals")
	def assertEquals(Object a, Object b) {
		if (asBinaryOperation("==").apply(a, b) == false)
			throw AssertionException.valueNotWasEquals(a, b)
	}

	@NativeMessage("notEquals")
	def assertNotEquals(Object a, Object b) {
		if (asBinaryOperation("==").apply(a, b) == true)
			throw AssertionException.valueNotWasNotEquals(a, b)
	}

}

@Accessors
class AssertionException extends Exception {
	val String expected
	val String actual

	new(String msg, String expected, String actual) {
		super(msg)
		this.expected = expected
		this.actual = actual
	}

	static def valueWasNotTrue() {
		return new AssertionException("Value was not true", "true", "false")
	}

	static def valueWasNotFalse() {
		return new AssertionException("Value was not false", "false", "true")
	}

	static def valueNotWasEquals(Object expected, Object actual) {
		return newException("Expected [{0}] but found [{1}]", expected, actual)
	}

	static def valueNotWasNotEquals(Object expected, Object actual) {
		return AssertionException.newException("Expected different to [{0}] but found [{1}]", expected, actual)
	}

	static def newException(String format, Object expected, Object actual) {
		val strExpected = if(expected == null) "null" else expected.toString
		val strActual = if(actual == null) "null" else actual.toString
		return new AssertionException(MessageFormat.format(format, strExpected, strActual), strExpected, strActual)
	}
}
