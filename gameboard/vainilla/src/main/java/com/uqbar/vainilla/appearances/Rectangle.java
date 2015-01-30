package com.uqbar.vainilla.appearances;


import java.awt.Color;
import java.awt.Graphics2D;
import com.uqbar.vainilla.GameComponent;

public class Rectangle implements Appearance {

	private Color color;
	private int width, height;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public Rectangle(Color color, int width, int height) {
		this.color = color;
		this.height = height;
		this.width = width;
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public Color getColor() {
		return color;
	}
	
	@Override
	public double getWidth() {
		return this.width;
	}

	@Override
	public double getHeight() {
		return this.height;
	}

	@Override
	@SuppressWarnings("unchecked")
	public Rectangle copy() {
		return new Rectangle(this.color, this.height, this.width);
	}

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void update(double delta) {
	}

	@Override
	public void render(GameComponent<?> component, Graphics2D graphics) {
		graphics.setColor(this.color);
		graphics.fillRect((int) component.getX(), (int) component.getY(), this.width, this.height);
	}
}
