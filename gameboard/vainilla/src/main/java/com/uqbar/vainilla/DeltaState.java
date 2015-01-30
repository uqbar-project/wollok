package com.uqbar.vainilla;

import java.awt.geom.Point2D;
import com.uqbar.vainilla.events.constants.Key;
import com.uqbar.vainilla.events.constants.MouseButton;

public interface DeltaState {

	public double getDelta();

	public abstract boolean isKeyPressed(Key key);

	public abstract boolean isKeyReleased(Key key);

	public abstract boolean isKeyBeingHold(Key key);

	public abstract boolean hasMouseMoved();

	public abstract boolean isMouseButtonPressed(MouseButton button);

	public abstract boolean isMouseButtonReleased(MouseButton button);

	public abstract boolean isMouseButtonBeingHold(MouseButton button);

	public abstract Point2D.Double getLastMousePosition();

	public abstract Point2D.Double getCurrentMousePosition();

}