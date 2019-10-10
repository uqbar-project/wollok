package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.audio.Sound
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Messages

@Accessors
class GameSound {
	String file
	long soundID
	float volume
	Sound sound

	def play() {
		soundID = fetchSound.play()
	}

	def stop() {
		fetchSound.stop()
	}

	def pause() {
		fetchSound.pause()
	}

	def resume() {
		fetchSound.resume()
	}

	def volume(float newVolume) {
		fetchSound.setVolume(soundID, newVolume)
	}
	
//	def volume(){
//	}

	def loop(boolean looping) {
		fetchSound.setLooping(soundID, looping)
	}

	def fetchSound() {
		if (Gdx.app === null)
			throw new RuntimeException(Messages.WollokGame_SoundGameNotStarted)

		if (sound === null) {
			try {
				val soundFile = Gdx.files.internal(file)
				sound = Gdx.audio.newSound(soundFile)
			} catch (Exception e) {
				println(NLS.bind(Messages.WollokGame_AudioNotFound, file))
			}
		}
		sound
	}

}
