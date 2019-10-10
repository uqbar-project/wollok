package wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.gameboard.GameSound
import org.uqbar.project.wollok.interpreter.core.WollokObject
import wollok.lang.AbstractJavaWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

@Accessors
class WSound extends AbstractJavaWrapper<GameSound> {

	def void play() {
		getWrapped.play()
	}

	def void stop() {
		getWrapped.stop()
	}

	def void pause() {
		getWrapped.pause()
	}

	def void resume() {
		getWrapped.resume()
	}

	def void volume(WollokObject newVolume) {
		getWrapped.volume(newVolume.asNumber.floatValue)
	}

	def void loop(boolean looping) {
		getWrapped.loop(looping)
	}

	override getWrapped() {
		if (wrapped === null) {
			val _file = obj.resolve("file").toWollokString
			wrapped = new GameSound => [file = _file]
		}
		wrapped
	}

}
