package com.uqbar.vainilla.events;

import com.uqbar.vainilla.ConcreteDeltaState;

public interface GameEvent {

	public void applyOn(ConcreteDeltaState state);
}