package org.uqbar.project.wollok.game.gameboard

import org.eclipse.xtend.lib.annotations.Accessors
import com.badlogic.gdx.Gdx
import com.badlogic.gdx.audio.Sound
import java.util.Map
import org.uqbar.project.wollok.game.Messages
import org.eclipse.osgi.util.NLS


@Accessors
class SoundAdapter {
	Map<String, Sound> audioFiles = <String, Sound>newHashMap
	public static SoundAdapter instance
	
	def static getInstance() {
		if (instance === null) {
			instance = new SoundAdapter()
		}
		instance
	}
	
	def fetchSound(String audioFile) {
		if (Gdx.app === null)
			throw new RuntimeException(Messages.WollokGame_SoundGameNotStarted)
			
		var sound = audioFiles.get(audioFile)
		if (sound === null) {
			try {
				val soundFile = Gdx.files.internal(audioFile)
				sound = Gdx.audio.newSound(soundFile)
				audioFiles.put(audioFile, sound)
			} catch (Exception e) {
				println(NLS.bind(Messages.WollokGame_AudioNotFound, audioFile))
			}
		}
		sound
	}
	
	def play(String file){
		file.fetchSound.play()
	}
	
	def loop(String file,long id,boolean looping){
		file.fetchSound.setLooping(id,looping)
	}
	def stop(String file){
		file.fetchSound.stop()
	}
	def volume(String file,long id,float newVolume){
		file.fetchSound.setVolume(id,newVolume)
	}
	def pause(String file){
		file.fetchSound.pause()
	}
	
}