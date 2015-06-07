import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations

/**
 * 
 * @author tesonep
 */
class TesterObject extends AbstractWollokDeclarativeNativeObject {

	extension WollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations
	
	@NativeMessage("assert")
	def assertMethod(Boolean value) {
		if (!value) 
			throw new AssertionError("Value was not true")
	}
	
	def assertFalse(Boolean value) {
		if (value) 
			throw new AssertionError("Value was not false")
	}
	
	def assertEquals(Object a, Object b) {
		// TODO: debería compararlos usando el intérprete, como si el usuario mismo
		// hubiera escrito "a != b". Sino acá está comparando según Java por identidad.
		if (asBinaryOperation("!=").apply(a,b) == true) 
			throw new AssertionError('''Expected [«a»] but found [«b»]''')
	}
}
