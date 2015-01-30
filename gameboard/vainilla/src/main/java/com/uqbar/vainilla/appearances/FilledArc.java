package com.uqbar.vainilla.appearances;


import com.uqbar.vainilla.GameComponent;

import java.awt.*;

public class FilledArc implements Appearance {

	private Color color;
	private final int radius;
	private final double startAngle;
	private final double arcAngle;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public FilledArc(Color color, int radius, double startAngle, double arcAngle) {
		this.color = color;
		this.radius = radius;
		this.startAngle = startAngle;
		this.arcAngle = arcAngle;
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	public double getWidth() {
		return this.radius * 2;
	}

	@Override
	public double getHeight() {
		return this.radius * 2;
	}

	@Override
	@SuppressWarnings("unchecked")
	public FilledArc copy() {
		return new FilledArc(this.color, this.radius, this.startAngle, this.arcAngle);
	}

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void update(double delta) {
	}

	@Override
	public void render(GameComponent<?> component, Graphics2D graphics) {
		int x = (int) (component.getX() );
		int y = (int) (component.getY() );

		graphics.setColor(this.color);
		graphics.fillArc(x, y, (int) this.getWidth(), (int) this.getHeight(), (int) this.startAngle,
				(int) this.arcAngle);
	}

    public Color getColor(){
        return color;
    }

    public void setColor(Color color){
        this.color = color;
    }

}