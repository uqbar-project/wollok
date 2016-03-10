package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import com.badlogic.gdx.ApplicationListener
import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration

class WollokGDXApplication extends LwjglApplication {
	
	new(ApplicationListener listener, LwjglApplicationConfiguration config) {
		super(listener, config)
		this.mainLoopThread.join
	}
	
}