package com.uqbar.vainilla.appearances;


import java.awt.Graphics2D;
import com.uqbar.vainilla.GameComponent;

public class Invisible implements Appearance {

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	public double getWidth() {
		return 0;
	}

	@Override
	public double getHeight() {
		return 0;
	}

	@Override
	@SuppressWarnings("unchecked")
	public Invisible copy() {
		return this;
	}

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void update(double delta) {
	}

	@Override
	public void render(GameComponent<?> component, Graphics2D graphics) {
	}
}