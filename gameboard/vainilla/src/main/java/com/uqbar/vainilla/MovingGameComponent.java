package com.uqbar.vainilla;

import com.uqbar.vainilla.appearances.Appearance;

/**
 * GameComponent with velocity (speed and unit vector)
 */
public class MovingGameComponent<SceneType extends GameScene> extends GameComponent<SceneType> {
	protected UnitVector2D uVector;
	protected double speed;

	public MovingGameComponent() {
		super();
		this.uVector = new UnitVector2D(1, 1);
		this.speed = 0;
	}

	public MovingGameComponent(double xPos, double yPos, double xVec,
			double yVec, double speed) {
		super(xPos, yPos);
		this.uVector = new UnitVector2D(xVec, yVec);
		this.speed = speed;
	}

	public MovingGameComponent(Appearance appearance, double xPos, double yPos,
			double xVec, double yVec, double speed) {
		super(appearance, xPos, yPos);
		this.uVector = new UnitVector2D(xVec, yVec);
		this.speed = speed;
	}

	@Override
	public void update(DeltaState deltaState) {
		double xPosition = this.getX() + this.getUVector().getX()
				* this.getSpeedFactor(deltaState);
		double yPosition = this.getY() + this.getUVector().getY()
				* this.getSpeedFactor(deltaState);
		this.setX(xPosition);
		this.setY(yPosition);

		super.update(deltaState);
	}

	public double getSpeedFactor(DeltaState deltaState) {
		return this.getSpeed() * deltaState.getDelta();
	}
	
    public void center() {
		this.setX(this.getScene().getGame().getDisplayWidth() / 2 - (this.getWidth() / 2));
	}

	public double getSpeed() {
		return this.speed;
	}

	public UnitVector2D getUVector() {
		return this.uVector;
	}

	public void setSpeed(double speed) {
		this.speed = speed;
	}

}
