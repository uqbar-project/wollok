package com.uqbar.vainilla.events;

import java.awt.geom.Point2D;

public abstract class MouseEvent extends SimpleEvent {

	private Point2D.Double position;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public MouseEvent(Point2D.Double position) {
		this.setPosition(position);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public Point2D.Double getPosition() {
		return this.position;
	}

	protected void setPosition(Point2D.Double position) {
		this.position = position;
	}
}