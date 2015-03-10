package wollok.lib

import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

class TesterObject extends AbstractWollokDeclarativeNativeObject {
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
		if (a != b)
			throw new AssertionError('''Expected [«a»] but found [«b»]''')
	}
}
