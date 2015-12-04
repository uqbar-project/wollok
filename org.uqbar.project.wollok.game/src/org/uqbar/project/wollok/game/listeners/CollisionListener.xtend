package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.VisualComponent
import java.util.function.Consumer
import org.uqbar.project.wollok.game.gameboard.Gameboard

/**
 * 
 */
class CollisionListener implements GameboardListener {
	VisualComponent component
	Consumer<VisualComponent> block

	new (VisualComponent component, Consumer<VisualComponent> block) {
		this.component = component
		this.block = block
	}

	override notify(Gameboard gameboard) {
		val c = gameboard.getComponentsInPosition(component.position)
		c.forEach[println(it)]
		c.filter[ it != component ]
			.forEach[ 
				block.accept(it)
			]
	}
}