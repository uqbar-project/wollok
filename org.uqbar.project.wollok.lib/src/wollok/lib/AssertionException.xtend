package wollok.lib

import java.text.MessageFormat
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.core.WollokObject

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
		return new AssertionFailException(message) {}
	}

	static def valueWasNotTrue() {
		return new ValueWasNotTrueException()
	}

	static def valueWasNotFalse() {
		return new ValueWasNotFalseException()
	}

	static def blockDidNotFail() {
		return new BlockDidNotFailException()
	}

	static def valueNotWasEquals(Object _expected, Object _actual) {
		val expected = _expected.printValue
		val actual = _actual.printValue
		return new ValueWasNotEqualsException(MessageFormat.format("Expected [{0}] but found [{1}]", expected, actual), expected, actual)
	}
	
	static def valueNotWasNotEquals(Object _expected, Object _actual) {
		val expected = _expected.printValue
		val actual = _actual.printValue
		return new ValueWasNotDifferentException(MessageFormat.format("Expected different to [{0}] but found [{1}]", expected, actual), expected, actual)
	}

	def static printValue(Object expected) {
		if (expected == null) return "null" 
		(expected as WollokObject).call("printString").toString
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

class BlockDidNotFailException extends AssertionException {
	new() {
		super("Block should have failed")
	}
}

class AssertionFailException extends AssertionException {
	new(String msg) {
		super(msg)
	}
}