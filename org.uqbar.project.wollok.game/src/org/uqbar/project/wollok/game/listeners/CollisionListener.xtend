package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard

/**
 * 
 */
class CollisionListener implements GameboardListener {
	VisualComponent component
	(VisualComponent)=>Object block

	new (VisualComponent component, (VisualComponent)=>Object block) {
		this.component = component
		this.block = block
	}

	override notify(Gameboard gameboard) {
		val c = gameboard.getComponentsInPosition(component.position)
		c.forEach[println(it)]
		c.filter[ it != component ]
			.forEach[ 
				block.apply(it)
			]
	}
}