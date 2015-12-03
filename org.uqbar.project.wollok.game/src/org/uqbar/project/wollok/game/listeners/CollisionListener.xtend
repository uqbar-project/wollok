package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.VisualComponent
import java.util.function.Consumer
import org.uqbar.project.wollok.game.gameboard.Gameboard

class CollisionListener implements GameboardListener {

	VisualComponent component;
	Consumer<VisualComponent> block;

	new (VisualComponent component, Consumer<VisualComponent> block) {
		this.component = component;
		this.block = block;
	}

	override notify(Gameboard gameboard) {
		var componets = gameboard.getComponentsInPosition(component.getPosition());
		for (VisualComponent visualComponent : componets) {
			if(!visualComponent.equals(component))
				block.accept(visualComponent);
		}
	}
}