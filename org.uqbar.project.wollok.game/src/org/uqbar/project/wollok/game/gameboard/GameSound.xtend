package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.audio.Sound
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Messages

@Accessors
class GameSound {
	String file
	Long soundID
	Sound sound
	Boolean looped = false
	Float volume = 1.0f
	Boolean paused = false

	def play() {
		if (played)
			throw new RuntimeException(Messages.WollokGame_SoundAlreadyPlayed)
		if (looped)
			soundID = fetchSound.play(volume)
		else
			soundID = fetchSound.loop(volume)
	}

	def played() {
		soundID !== null
	}

	def stop() {
		if(!played)
			throw new RuntimeException(Messages.WollokGame_SoundNotYetPlayed)
		fetchSound.stop()
		fetchSound.dispose()
	}

	def pause() {
		if (!played)
			throw new RuntimeException(Messages.WollokGame_PausedANotPlayedSound)
		if (paused)
			throw new RuntimeException(Messages.WollokGame_SoundAlreadyPaused)
		fetchSound.pause()
		paused = true
	}

	def resume() {
		if (!played)
			throw new RuntimeException(Messages.WollokGame_PausedANotPlayedSound)
		if (!paused)
			throw new RuntimeException(Messages.WollokGame_SoundAlreadyPlaying)
		fetchSound.resume()
		paused = false
	}

	def isPaused() {
		paused
	}

	def volume(Float newVolume) {
		if (newVolume < 0 || newVolume > 1)
			throw new RuntimeException(Messages.WollokGame_VolumeOutOfRange)
		volume = newVolume
		syncVolume()
	}

	def volume() {
		volume
	}

	def syncVolume() {
		if (played()) {
			fetchSound.setVolume(soundID, volume)
		}
	}

	def shouldLoop(Boolean looping) {
		looped = looping
		syncLoop()
	}

	def shouldLoop() {
		looped
	}

	def syncLoop() {
		if (played()) {
			fetchSound.setLooping(soundID, looped)
		}
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
