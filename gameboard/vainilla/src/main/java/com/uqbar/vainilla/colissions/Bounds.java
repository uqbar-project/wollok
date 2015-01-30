package com.uqbar.vainilla.colissions;

import com.uqbar.vainilla.GameComponent;

public class Bounds {

	private double x;
	private double y;
	private double width;
	private double height;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public Bounds(double x, double y, double width, double height) {
		this.setX(x);
		this.setY(y);
		this.setWidth(width);
		this.setHeight(height);
	}
	
	public Bounds(GameComponent<?> component) {
		this(component.getX(), component.getY(), component.getWidth(), component.getHeight());
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public double getTop() {
		return this.getY();
	}

	public double getRight() {
		return this.getX() + this.getWidth();
	}

	public double getBottom() {
		return this.getY() + this.getHeight();
	}

	public double getLeft() {
		return this.getX();
	}

	public double getCenterX() {
		return this.getX() + this.getWidth() / 2;
	}

	public double getCenterY() {
		return this.getY() + this.getHeight() / 2;
	}

	public boolean contains(double x2, double y2) {
		return x2 >= this.getLeft() && x2 <= this.getRight()
				&& y2 >= this.getTop() && y2 <= this.getBottom();
	}

	public boolean contains(Bounds bounds) {
		return bounds.getLeft() >= this.getLeft()
				&& bounds.getRight() <= this.getRight()
				&& bounds.getTop() >= this.getTop()
				&& bounds.getBottom() <= this.getBottom();
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected double getX() {
		return this.x;
	}

	protected void setX(double x) {
		this.x = x;
	}

	protected double getY() {
		return this.y;
	}

	protected void setY(double y) {
		this.y = y;
	}

	protected void setWidth(double width) {
		this.width = width;
	}

	public double getWidth() {
		return this.width;
	}

	protected void setHeight(double height) {
		this.height = height;
	}

	public double getHeight() {
		return this.height;
	}

}