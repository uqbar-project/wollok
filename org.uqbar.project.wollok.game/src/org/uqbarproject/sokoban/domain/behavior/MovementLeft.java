package org.uqbarproject.sokoban.domain.behavior;

public class MovementLeft implements Movement {

	@Override
	public void move(Position aPosition, int spaces) {
		aPosition.setX(aPosition.getX() - spaces);
	}

}
