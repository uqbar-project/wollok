package com.uqbar.vainilla;

import static java.lang.Math.abs;
import static java.lang.Math.min;

import java.awt.Graphics2D;

import com.uqbar.vainilla.appearances.Appearance;
import com.uqbar.vainilla.appearances.Invisible;
import com.uqbar.vainilla.colissions.Circle;
import com.uqbar.vainilla.colissions.Rectangle;

public class GameComponent<SceneType extends GameScene> {
	private SceneType scene;
	private Appearance appearance;
	private double x;
	private double y;
	private int z;
	private boolean destroyPending;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public GameComponent() {
		this(new Invisible(), 0, 0);
	}

	public GameComponent(double x, double y) {
		this(new Invisible(), x, y);
	}

	public GameComponent(Appearance appearance, double x, double y) {
		this.setAppearance(appearance);
		this.setX(x);
		this.setY(y);
	}

	// ****************************************************************
	// ** QUERIES
	// ****************************************************************

	public Game getGame() {
		return this.getScene().getGame();
	}

	// ****************************************************************
	// ** INITIALIZATION
	// ****************************************************************

	public void onSceneActivated() {
	}

	// ****************************************************************
	// ** OPERATIONS
	// ****************************************************************

	public void move(double dx, double dy) {
		this.setX(this.getX() + dx);
		this.setY(this.getY() + dy);
	}

	public void destroy() {
		this.setDestroyPending(true);
	}

	// ****************************************************************
	// ** ALIGNMENT OPERATIONS
	// ****************************************************************
	
	public void horizontalCenterRespect(GameComponent<?> component) {
		this.alignHorizontalCenterTo(component.getX() + component.getWidth() / 2);
	}
	
	public void verticalCenterRespect(GameComponent<?> component) {
		this.alignVerticalCenterTo(component.getY() + component.getHeight() / 2);
	}

	public void alignTopTo(double y) {
		this.move(0, y - this.getY());
	}

	public void alignLeftTo(double x) {
		this.move(x - this.getX(), 0);
	}

	public void alignBottomTo(double y) {
		this.alignTopTo(y + this.getAppearance().getHeight());
	}

	public void alignRightTo(double x) {
		this.alignRightTo(x + this.getAppearance().getWidth());
	}

	public void alignHorizontalCenterTo(double x) {
		this.alignLeftTo(x - this.getAppearance().getWidth() / 2);
	}

	public void alignVerticalCenterTo(double y) {
		this.alignTopTo(y - this.getAppearance().getHeight() / 2);
	}

	public void alignCloserBoundTo(GameComponent<?> target) {
		Appearance ownBounds = this.getAppearance();
		Appearance targetBounds = target.getAppearance();
		double bottomDistance = abs(ownBounds.getHeight() + this.getY() - target.getY());
		double targetRight = target.getX() + targetBounds.getWidth();
		double leftDistance = abs(this.getX() - targetRight);
		double targetBottom = target.getY() + targetBounds.getHeight();
		double topDistance = abs(this.getY() - targetBottom);
		double rightDistance = abs(this.getX() + ownBounds.getWidth() - target.getX());
		double minDistance = min(bottomDistance, min(leftDistance, min(topDistance, rightDistance)));

		if(minDistance == bottomDistance) {
			this.alignBottomTo(target.getY());
		}
		else if(minDistance == leftDistance) {
			this.alignLeftTo(targetRight);
		}
		else if(minDistance == topDistance) {
			this.alignTopTo(targetBottom);
		}
		else {
			this.alignRightTo(target.getX());
		}
	}

	// ****************************************************************
	// ** GAME OPERATIONS
	// ****************************************************************

	public void render(Graphics2D graphics) {
		this.getAppearance().render(this, graphics);
	}

	public void update(DeltaState deltaState) {
		this.getAppearance().update(deltaState.getDelta());
	}
	
	public void collide(GameComponent<?> component) {}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public double getWidth() {
		return this.getAppearance().getWidth();
	}
	
	public double getHeight() {
		return this.getAppearance().getHeight();
	}
	
	public Rectangle getRect() {
		return new Rectangle(this.getX(), this.getY(), this.getWidth(), this.getHeight());
	}
	
	public Circle getCirc() {
		return new Circle(this.getX(), this.getY(), Math.max(this.getWidth(), this.getHeight()));
	}
	
	public SceneType getScene() {
		return this.scene;
	}

	protected void setScene(SceneType scene) {
		this.scene = scene;
		this.nowOnScene();
	}

	/** 
	 * template method for subclasses to perform some action once they are added to a scene 
	 */
	protected void nowOnScene() {
	}

	public Appearance getAppearance() {
		return this.appearance;
	}

	public void setAppearance(Appearance appearance) {
		this.appearance = appearance;
	}

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

	public int getZ() {
		return this.z;
	}

	public void setZ(int z) {
		this.z = z;
	}

	public boolean isDestroyPending() {
		return this.destroyPending;
	}

	protected void setDestroyPending(boolean destroyPending) {
		this.destroyPending = destroyPending;
	}

}