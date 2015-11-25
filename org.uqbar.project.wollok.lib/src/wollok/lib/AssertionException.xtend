package wollok.lib

import java.text.MessageFormat
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.core.runtime.AssertionFailedException

/**
 * This exceptions are thrown when an assert is not ok.
 * @author tesonep
 */
@Accessors
abstract class AssertionException extends Exception {
	val String expected
	val String actual

	new(String msg, String expected, String actual) {
		super(msg)
		this.expected = expected
		this.actual = actual
	}

	new(String msg) {
		super(msg)
		expected = null
		actual = null
	}

	static def fail(String message) {
		return new AssertionFailedException(message) {}
	}

	static def valueWasNotTrue() {
		return new ValueWasNotTrueException()
	}

	static def valueWasNotFalse() {
		return new ValueWasNotFalseException()
	}

	static def valueNotWasEquals(Object expected, Object actual) {
		val strExpected = if(expected == null) "null" else expected.toString
		val strActual = if(actual == null) "null" else actual.toString
		return new ValueWasNotEqualsException(MessageFormat.format("Expected [{0}] but found [{1}]", strExpected, strActual), strExpected, strActual)
	}

	static def valueNotWasNotEquals(Object expected, Object actual) {
		val strExpected = if(expected == null) "null" else expected.toString
		val strActual = if(actual == null) "null" else actual.toString
		return new ValueWasNotDifferentException(MessageFormat.format("Expected different to [{0}] but found [{1}]", strExpected, strActual), strExpected, strActual)
	}
}

class ValueWasNotEqualsException extends AssertionException {
	new(String msg, String expected, String actual) {
		super(msg,expected,actual)
	}
}

class ValueWasNotDifferentException extends AssertionException {
	new(String msg, String expected, String actual) {
		super(msg,expected,actual)
	}
}

class ValueWasNotTrueException extends AssertionException {
	new() {
		super("Value was not true")
	}
}

class ValueWasNotFalseException extends AssertionException {
	new() {
		super("Value was not false")
	}
}
