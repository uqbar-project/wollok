import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage

class JuanceteObject extends AbstractWollokDeclarativeNativeObject {
	
	@NativeMessage("sayMyName")
	def diMiNombre(){
		WollokInterpreter.getInstance().getConsole().logMessage("Juancete")
	}

	@NativeMessage("launchWollokGame")
	def launchGame(){
		
	}
}