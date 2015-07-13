package org.uqbarproject.sokoban.domain.behavior;

public class MovementDown implements Movement {

	@Override
	public void move(Position aPosition, int spaces) {
		aPosition.setY(aPosition.getY() + spaces);
	}

}
