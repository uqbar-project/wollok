package com.uqbar.vainilla.events;

import com.uqbar.vainilla.ConcreteDeltaState;
import com.uqbar.vainilla.events.constants.Key;

public class KeyPressedEvent extends KeyEvent {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public KeyPressedEvent(Key key) {
		super(key);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	@Override
	public void applyOn(ConcreteDeltaState state) {
		state.setKeyPressed(this.getKey());
	}
}