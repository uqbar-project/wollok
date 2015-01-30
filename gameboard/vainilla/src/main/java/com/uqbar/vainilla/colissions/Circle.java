package com.uqbar.vainilla.colissions;

import com.uqbar.vainilla.Posicionable;

public class Circle extends Posicionable {

	private double diameter;
	
	public Circle(double x, double y, double diameter) {
		super(x, y);
		this.setDiameter(diameter);
	}

	public double getDiameter() {
		return diameter;
	}

	public void setDiameter(double diameter) {
		this.diameter = diameter;
	}

	public double getRadio() {
		return this.getDiameter() / 2;
	}
	
}
