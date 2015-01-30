package org.uqbar.wollok.rpg

import com.uqbar.vainilla.DesktopGameLauncher
import com.uqbar.vainilla.Game
import java.awt.Dimension
import org.uqbar.wollok.rpg.scenes.WollokRPGScene

/**
 * Vainilla's implementation of a wollok
 * board for rpg-like games. 
 * 
 * @author jfernandes
 */
class WollokRPGGame extends Game {
	var Dimension dimension;
	
	override initializeResources() {
		dimension = new Dimension(720, 480)
	}

	override setUpScenes() {
		currentScene = new WollokRPGScene(this)
	}

	override getDisplaySize() { dimension }

	override getTitle() { "Wollok RPG Board" }

	def static main(String[] args) throws Exception {
		new DesktopGameLauncher(new WollokRPGGame()).launch();
	}
	
}