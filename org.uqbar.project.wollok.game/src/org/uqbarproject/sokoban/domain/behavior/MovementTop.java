package org.uqbarproject.sokoban.domain.behavior;

public class MovementTop implements Movement {

	@Override
	public void move(Position aPosition, int spaces) {
		aPosition.setY(aPosition.getY() - spaces);
	}

}
