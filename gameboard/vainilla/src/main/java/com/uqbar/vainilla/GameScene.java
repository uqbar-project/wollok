package com.uqbar.vainilla;

import java.awt.Graphics2D;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import com.uqbar.vainilla.events.EventQueue;
import com.uqbar.vainilla.events.GameEvent;

public class GameScene {

	private Game game;
	private List<GameComponent<?>> components;
	private EventQueue eventQueue;
	private double lastUpdateTime;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public GameScene() {
		this.setComponents(new ArrayList<GameComponent<?>>());
		this.setEventQueue(new EventQueue());
	}

	public GameScene(GameComponent<? extends GameScene>... components) {
		this(Arrays.asList(components));
	}

	public GameScene(Collection<? extends GameComponent<? extends GameScene>> components) {
		this();

		for(GameComponent<? extends GameScene> component : components) {
			this.addComponent(component);
		}
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public int getComponentCount() {
		return this.getComponents().size();
	}

	protected int getZFromComponentAt(int index) {
		return this.getComponents().get(index).getZ();
	}

	protected int indexToInsert(GameComponent<?> component) {
		int lowerIndex = 0;
		int higherIndex = this.getComponentCount() - 1;
		int searchedZ = component.getZ();

		if(this.getComponents().isEmpty() || searchedZ < this.getZFromComponentAt(lowerIndex)) {
			return 0;
		}

		if(searchedZ >= this.getZFromComponentAt(higherIndex)) {
			return this.getComponentCount();
		}

		while(lowerIndex <= higherIndex) {
			int middleIndex = lowerIndex + higherIndex >>> 1;
			int middleZ = this.getZFromComponentAt(middleIndex);

			if(middleZ <= searchedZ) {
				lowerIndex = middleIndex + 1;
			}
			else if(middleZ > searchedZ) {
				higherIndex = middleIndex - 1;
			}
		}

		return lowerIndex;
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void onSetAsCurrent() {
		for(GameComponent<?> component : this.components) {
			component.onSceneActivated();
		}
	}

	public void pushEvent(GameEvent event) {
		this.getEventQueue().pushEvent(event);
	}

	public void takeStep(Graphics2D graphics) {
		long now = System.nanoTime();
		double delta = this.getLastUpdateTime() > 0 ? (now - this.getLastUpdateTime()) / 1000000000L : 0;
		if(delta > 1) {
			delta = 0;
		}
		this.setLastUpdateTime(now);

		DeltaState state = this.getEventQueue().takeState(delta);

		for(GameComponent<?> component : new ArrayList<GameComponent<?>>(this.getComponents())) {
			if(component.isDestroyPending()) {
				this.removeComponent(component);
			}
			else {
				component.update(state);
				component.render(graphics);
			}
		}
	}

	// ****************************************************************
	// ** ACCESS OPERATIONS
	// ****************************************************************

	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void addComponent(GameComponent component) {
		this.getComponents().add(this.indexToInsert(component), component);

		component.setScene(this);
	}

	public void addComponents(GameComponent<?>... components) {
		for(GameComponent<?> component : components) {
			this.addComponent(component);
		}
	}

	public void addComponents(Collection<? extends GameComponent<?>> components) {
		for(GameComponent<?> component : components) {
			this.addComponent(component);
		}
	}

	public void removeComponent(GameComponent<?> component) {
		this.getComponents().remove(component);

		component.setScene(null);
	}

	public void removeComponents(GameComponent<?>... components) {
		for(GameComponent<?> component : components) {
			this.removeComponent(component);
		}
	}

	public void removeComponents(Collection<? extends GameComponent<?>> components) {
		for(GameComponent<?> component : components) {
			this.removeComponent(component);
		}
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public Game getGame() {
		return this.game;
	}

	public void setGame(Game game) {
		this.game = game;
	}

	protected List<GameComponent<?>> getComponents() {
		return this.components;
	}

	protected void setComponents(List<GameComponent<?>> components) {
		this.components = components;
	}

	protected EventQueue getEventQueue() {
		return this.eventQueue;
	}

	protected void setEventQueue(EventQueue eventQueue) {
		this.eventQueue = eventQueue;
	}

	protected double getLastUpdateTime() {
		return this.lastUpdateTime;
	}

	public void setLastUpdateTime(double lastUpdateTime) {
		this.lastUpdateTime = lastUpdateTime;
	}

}