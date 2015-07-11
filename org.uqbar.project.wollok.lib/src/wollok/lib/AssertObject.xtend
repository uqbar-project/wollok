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
			throw new AssertionException("Value was not true")
	}
	
	@NativeMessage("notThat")
	def assertFalse(Boolean value) {
		if (value) 
			throw new AssertionException("Value was not false")
	}
	
	@NativeMessage("equals")
	def assertEquals(Object a, Object b) {
		// TODO: debería compararlos usando el intérprete, como si el usuario mismo
		// hubiera escrito "a == b". Sino acá está comparando según Java por identidad.
		if (asBinaryOperation("==").apply(a,b) == false) 
			throw new AssertionException('''Expected [«a»] but found [«b»]''')
	}

	@NativeMessage("notEquals")
	def assertNotEquals(Object a, Object b) {
		// TODO: debería compararlos usando el intérprete, como si el usuario mismo
		// hubiera escrito "a == b". Sino acá está comparando según Java por identidad.
		if (asBinaryOperation("==").apply(a,b) == true) 
			throw new AssertionException('''Expected different to [«a»] but found [«b»]''')
	}

}

class AssertionException extends Exception {
	new(String msg){
		super(msg)
	}
}
