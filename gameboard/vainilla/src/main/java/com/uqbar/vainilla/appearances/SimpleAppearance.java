package com.uqbar.vainilla.appearances;

import java.awt.Graphics2D;
import com.uqbar.vainilla.GameComponent;

public abstract class SimpleAppearance<T extends Appearance> implements Appearance, Cloneable {

	private double x;
	private double y;

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	@Override
	@SuppressWarnings("unchecked")
	public T copy() {
		try {
			return (T) this.clone();
		}
		catch(CloneNotSupportedException e) {
			throw new RuntimeException(e);
		}
	}

	// ****************************************************************
	// ** SCALING
	// ****************************************************************

	public T scale(double scale) {
		return this.scale(scale, scale);
	}

	public T scaleHorizontally(double scale) {
		return this.scale(scale, 1);
	}

	public T scaleVertically(double scale) {
		return this.scale(1, scale);
	}

	public T scaleTo(double width, double height) {
		double horizontalScale = width / this.getWidth();
		double verticalScale = height / this.getHeight();

		return this.scale(horizontalScale, verticalScale);
	}

	public T scaleHorizontallyTo(double width, boolean keepAspectRatio) {
		double scale = width / this.getWidth();

		return this.scale(scale, keepAspectRatio ? scale : 1);
	}

	public T scaleVerticallyTo(int height, boolean keepAspectRatio) {
		double scale = height / this.getHeight();

		return this.scale(keepAspectRatio ? scale : 1, scale);
	}

	public abstract T scale(double scaleX, double scaleY);

	// ****************************************************************
	// ** GAME LOOP OPERATIONS
	// ****************************************************************

	@Override
	public void render(GameComponent<?> component, Graphics2D graphics) {
		this.renderAt((int) component.getX(), (int) component.getY(), graphics);
	}

	public void renderAt(int x, int y, Graphics2D graphics) {
		this.doRenderAt(x + (int) this.getX(), y + (int) this.getY(), graphics);
	}

	protected abstract void doRenderAt(int x, int y, Graphics2D graphics);

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public double getX() {
		return this.x;
	}

	public void setX(double x) {
		this.x = x;
	}

	public double getY() {
		return this.y;
	}

	public void setY(double y) {
		this.y = y;
	}
}