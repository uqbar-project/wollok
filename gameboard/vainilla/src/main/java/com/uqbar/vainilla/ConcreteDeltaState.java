package com.uqbar.vainilla;

import java.awt.geom.Point2D;
import java.util.HashSet;
import java.util.Set;
import com.uqbar.vainilla.events.constants.Key;
import com.uqbar.vainilla.events.constants.MouseButton;

public class ConcreteDeltaState implements DeltaState {

	private double delta;
	private Set<Key> pressedKeys;
	private Set<Key> releasedKeys;
	private Set<Key> holdedKeys;
	private Point2D.Double lastMousePosition;
	private Point2D.Double currentMousePosition;
	private Set<MouseButton> pressedMouseButtons;
	private Set<MouseButton> releasedMouseButtons;
	private Set<MouseButton> holdedMouseButtons;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public ConcreteDeltaState() {
		this.setPressedKeys(new HashSet<Key>());
		this.setReleasedKeys(new HashSet<Key>());
		this.setHoldedKeys(new HashSet<Key>());
		this.setLastMousePosition(new Point2D.Double(-100, -100));
		this.setCurrentMousePosition(new Point2D.Double(-100, -100));
		this.setPressedMouseButtons(new HashSet<MouseButton>());
		this.setHoldedMouseButtons(new HashSet<MouseButton>());
		this.setReleasedMouseButtons(new HashSet<MouseButton>());

		this.reset();
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	public boolean isKeyPressed(Key key) {
		return this.getPressedKeys().contains(key);
	}

	@Override
	public boolean isKeyReleased(Key key) {
		return this.getReleasedKeys().contains(key);
	}

	@Override
	public boolean isKeyBeingHold(Key key) {
		return this.getHoldedKeys().contains(key);
	}

	@Override
	public boolean hasMouseMoved() {
		return this.getCurrentMousePosition() != this.getLastMousePosition();
	}

	@Override
	public boolean isMouseButtonPressed(MouseButton button) {
		return this.getPressedMouseButtons().contains(button);
	}

	@Override
	public boolean isMouseButtonReleased(MouseButton button) {
		return this.getReleasedMouseButtons().contains(button);
	}

	@Override
	public boolean isMouseButtonBeingHold(MouseButton button) {
		return this.getHoldedMouseButtons().contains(button);
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void reset() {
		this.getPressedKeys().clear();
		this.getReleasedKeys().clear();
		this.setLastMousePosition(this.getCurrentMousePosition());
		this.getPressedMouseButtons().clear();
		this.getReleasedMouseButtons().clear();
	}

	public void setKeyPressed(Key key) {
		this.getPressedKeys().add(key);
		this.getHoldedKeys().add(key);
	}

	public void setKeyReleased(Key key) {
		this.getReleasedKeys().add(key);
		this.getHoldedKeys().remove(key);
	}

	public void setMousePosition(Point2D.Double position) {
		this.setCurrentMousePosition(position);
	}

	public void setMouseButtonPressed(MouseButton button) {
		this.getPressedMouseButtons().add(button);
		this.getHoldedMouseButtons().add(button);
	}

	public void setMouseButtonReleased(MouseButton button) {
		this.getReleasedMouseButtons().add(button);
		this.getHoldedMouseButtons().remove(button);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	@Override
	public double getDelta() {
		return this.delta;
	}

	public void setDelta(double delta) {
		this.delta = delta;
	}

	protected Set<Key> getPressedKeys() {
		return this.pressedKeys;
	}

	protected void setPressedKeys(Set<Key> pressedKeys) {
		this.pressedKeys = pressedKeys;
	}

	protected Set<Key> getReleasedKeys() {
		return this.releasedKeys;
	}

	protected void setReleasedKeys(Set<Key> releasedKeys) {
		this.releasedKeys = releasedKeys;
	}

	protected Set<Key> getHoldedKeys() {
		return this.holdedKeys;
	}

	protected void setHoldedKeys(Set<Key> holdedKeys) {
		this.holdedKeys = holdedKeys;
	}

	@Override
	public Point2D.Double getLastMousePosition() {
		return this.lastMousePosition;
	}

	protected void setLastMousePosition(Point2D.Double lastMousePosition) {
		this.lastMousePosition = lastMousePosition;
	}

	@Override
	public Point2D.Double getCurrentMousePosition() {
		return this.currentMousePosition;
	}

	protected void setCurrentMousePosition(Point2D.Double currentMousePosition) {
		this.currentMousePosition = currentMousePosition;
	}

	protected Set<MouseButton> getPressedMouseButtons() {
		return this.pressedMouseButtons;
	}

	protected void setPressedMouseButtons(Set<MouseButton> pressedMouseButtons) {
		this.pressedMouseButtons = pressedMouseButtons;
	}

	protected Set<MouseButton> getReleasedMouseButtons() {
		return this.releasedMouseButtons;
	}

	protected void setReleasedMouseButtons(Set<MouseButton> releasedMouseButtons) {
		this.releasedMouseButtons = releasedMouseButtons;
	}

	protected Set<MouseButton> getHoldedMouseButtons() {
		return this.holdedMouseButtons;
	}

	protected void setHoldedMouseButtons(Set<MouseButton> holdedMouseButtons) {
		this.holdedMouseButtons = holdedMouseButtons;
	}
}