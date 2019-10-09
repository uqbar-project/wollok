package wollok.game

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterEvaluator
import org.uqbar.project.wollok.game.gameboard.SoundAdapter

import static org.uqbar.project.wollok.sdk.WollokSDK.*

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*
import org.uqbar.project.wollok.interpreter.core.WollokObject

@Accessors
class Sound {
	String file
	long soundID
	float volume
	 
	def initialize(String _file){
		file=_file
	}

	def wObject() {
		return (WollokInterpreter.getInstance().getEvaluator() as WollokInterpreterEvaluator).newInstance(SOUND) => []
	}
	
	def volume(float newVolume) {
		volume=newVolume
		SoundAdapter.getInstance.volume(file,soundID,volume)
	}
	def pause() {
		SoundAdapter.getInstance.pause(file)
	}

	def void play() {
		soundID=SoundAdapter.getInstance.play(file)
	}

	def stop() {
		SoundAdapter.getInstance.stop(file)
	}

	def loop(boolean looping) {
		SoundAdapter.getInstance.loop(file,soundID,looping)
	}

}
