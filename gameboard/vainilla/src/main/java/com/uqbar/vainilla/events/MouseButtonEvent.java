package com.uqbar.vainilla.events;

import java.awt.geom.Point2D;
import com.uqbar.vainilla.events.constants.MouseButton;

public abstract class MouseButtonEvent extends MouseEvent {

	private MouseButton button;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public MouseButtonEvent(Point2D.Double position, MouseButton button) {
		super(position);

		this.setButton(button);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public MouseButton getButton() {
		return this.button;
	}

	protected void setButton(MouseButton button) {
		this.button = button;
	}
}