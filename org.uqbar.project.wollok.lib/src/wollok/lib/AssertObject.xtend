package wollok.lib

import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

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
		if (asBinaryOperation("==").apply(a, [|b]) == false)
			throw AssertionException.valueNotWasEquals(a, b)
	}

	@NativeMessage("notEquals")
	def assertNotEquals(Object a, Object b) {
		if (asBinaryOperation("==").apply(a, [|b]) == true)
			throw AssertionException.valueNotWasNotEquals(a, b)
	}

}
