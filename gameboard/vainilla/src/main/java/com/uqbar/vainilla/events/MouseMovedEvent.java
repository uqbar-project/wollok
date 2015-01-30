package com.uqbar.vainilla.events;

import java.awt.geom.Point2D;
import com.uqbar.vainilla.ConcreteDeltaState;

public class MouseMovedEvent extends MouseEvent {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public MouseMovedEvent(Point2D.Double position) {
		super(position);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	public void applyOn(ConcreteDeltaState state) {
		state.setMousePosition(this.getPosition());
	}
}