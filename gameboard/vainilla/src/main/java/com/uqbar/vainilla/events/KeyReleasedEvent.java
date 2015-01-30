package com.uqbar.vainilla.events;

import com.uqbar.vainilla.ConcreteDeltaState;
import com.uqbar.vainilla.events.constants.Key;

public class KeyReleasedEvent extends KeyEvent {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public KeyReleasedEvent(Key key) {
		super(key);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	public void applyOn(ConcreteDeltaState state) {
		state.setKeyReleased(this.getKey());
	}
}