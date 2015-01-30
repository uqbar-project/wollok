package com.uqbar.vainilla.events;

import java.awt.geom.Point2D;
import com.uqbar.vainilla.ConcreteDeltaState;
import com.uqbar.vainilla.events.constants.MouseButton;

public class MousePressedEvent extends MouseButtonEvent {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public MousePressedEvent(Point2D.Double position, MouseButton button) {
		super(position, button);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	public void applyOn(ConcreteDeltaState state) {
		state.setMouseButtonPressed(this.getButton());
	}
}