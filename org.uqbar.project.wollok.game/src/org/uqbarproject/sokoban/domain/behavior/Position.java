package org.uqbarproject.sokoban.domain.behavior;

public class Position {
	private int x;
	private int y;
	
	public Position(int x, int y) {
		this.setX(x);
		this.setY(y);
	}
	public int getX() {
		return x;
	}
	public void setX(int x) {
		this.x = x;
	}
	public int getY() {
		return y;
	}
	public void setY(int y) {
		this.y = y;
	}
	public Position clone(Movement aMovement, int spaces){
		Position newPosition = new Position(getX(), getY());
		aMovement.move(newPosition, spaces);
		return newPosition;
	}
	@Override
	public boolean equals(Object other){
		return (this.getX() == ((Position) other).getX() && this.getY() == ((Position) other).getY());
		
	}
	
}
