import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage
import org.uqbar.project.wollok.game.gameboard.Gameboard

class WgameObject extends AbstractWollokDeclarativeNativeObject {
	
	@NativeMessage("sayMyName")
	def diMiNombre(){
		WollokInterpreter.getInstance().getConsole().logMessage("Juancete")
	}

	@NativeMessage("getGameboard")
	def getGameboardMethod(){
		var game = Gameboard.getInstance()
		game.tittle = "Tu vieja"
		game.cantCellX = 3
		game.cantCellY = 3
		game 
	}
}