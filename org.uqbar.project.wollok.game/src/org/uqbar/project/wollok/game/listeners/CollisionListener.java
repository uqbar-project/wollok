package org.uqbar.project.wollok.game.listeners;

import java.util.Collection;
import java.util.function.Consumer;

import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

public class CollisionListener implements GameboardListener {

	private VisualComponent component;
	private Consumer<VisualComponent> block;

	public CollisionListener(VisualComponent component, Consumer<VisualComponent> block) {
		this.component = component;
		this.block = block;
	}

	@Override
	public void notify(Gameboard gameboard) {
		Collection<VisualComponent> componets =
				gameboard.getComponentsInPosition(component.getPosition());
		for (VisualComponent visualComponent : componets) {
			if(!visualComponent.equals(component))
				block.accept(visualComponent);
		}
	}

}
