package com.uqbar.vainilla.events;

import java.util.ArrayList;
import java.util.Collection;
import com.uqbar.vainilla.ConcreteDeltaState;
import com.uqbar.vainilla.DeltaState;

public class EventQueue {

	private Collection<GameEvent> events;
	private ConcreteDeltaState deltaState;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public EventQueue() {
		this.setDeltaState(new ConcreteDeltaState());

		this.resetEvents();
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public synchronized void pushEvent(GameEvent event) {
		this.getEvents().add(event);
	}

	public DeltaState takeState(double delta) {
		this.getDeltaState().reset();

		this.getDeltaState().setDelta(delta);

		for(GameEvent event : this.takePendingEvents()) {
			event.applyOn(this.getDeltaState());
		}

		return this.getDeltaState();
	}

	protected synchronized Collection<GameEvent> takePendingEvents() {
		Collection<GameEvent> answer = this.getEvents();

		this.resetEvents();

		return answer;
	}

	protected void resetEvents() {
		this.setEvents(new ArrayList<GameEvent>());
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected Collection<GameEvent> getEvents() {
		return this.events;
	}

	protected void setEvents(Collection<GameEvent> events) {
		this.events = events;
	}

	protected ConcreteDeltaState getDeltaState() {
		return this.deltaState;
	}

	protected void setDeltaState(ConcreteDeltaState deltaState) {
		this.deltaState = deltaState;
	}
}