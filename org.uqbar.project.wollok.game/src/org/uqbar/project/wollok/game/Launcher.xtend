package org.uqbar.project.wollok.game

import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration
import com.badlogic.gdx.backends.lwjgl.LwjglApplication
import org.uqbar.project.wollok.game.setup.SokobanGame

class Launcher {
	
	LwjglApplicationConfiguration cfg
	
	def void launch() throws Exception {
		System.out.println("Lanzando Wollok Game...");
		cfg = new LwjglApplicationConfiguration();
		cfg.title = "sokoban";
		cfg.useGL30 = false;
		cfg.width = 480;
		cfg.height = 320;
		
		new LwjglApplication(new SokobanGame(), cfg);		
	}
	
}