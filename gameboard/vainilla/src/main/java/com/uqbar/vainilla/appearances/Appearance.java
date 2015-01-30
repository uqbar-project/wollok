package com.uqbar.vainilla.appearances;

import java.awt.Graphics2D;
import com.uqbar.vainilla.GameComponent;

public interface Appearance {

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public double getWidth();

	public double getHeight();

	public <T extends Appearance> T copy();

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	public void update(double delta);

	public void render(GameComponent<?> component, Graphics2D graphics);

	
}