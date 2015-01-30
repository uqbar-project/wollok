package com.uqbar.vainilla;

import java.awt.Dimension;
import java.awt.Graphics2D;

import com.uqbar.vainilla.events.GameEvent;

public abstract class Game {

	private GameScene currentScene;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public Game() {
		this.setCurrentScene(new GameScene());

		this.initializeResources();
		this.setUpScenes();
	}

	// ****************************************************************
	// ** INITIALIZATIONS
	// ****************************************************************

	protected abstract void initializeResources();

	protected abstract void setUpScenes();

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public int getDisplayWidth() {
		return this.getDisplaySize().width;
	}

	public int getDisplayHeight() {
		return this.getDisplaySize().height;
	}

	public abstract Dimension getDisplaySize();

	public abstract String getTitle();

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void takeStep(Graphics2D graphics) {
		this.getCurrentScene().takeStep(graphics);
	}

	public void pause() {
	}

	public void pushEvent(GameEvent event) {
		this.getCurrentScene().pushEvent(event);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public GameScene getCurrentScene() {
		return this.currentScene;
	}

	public void setCurrentScene(GameScene scene) {
		if(this.getCurrentScene() != null) {
			this.getCurrentScene().setGame(null);
		}

		this.currentScene = scene;

		scene.setGame(this);

		scene.onSetAsCurrent();
	}

	
}