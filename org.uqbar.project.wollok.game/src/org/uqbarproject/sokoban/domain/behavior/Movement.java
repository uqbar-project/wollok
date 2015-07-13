package org.uqbarproject.sokoban.domain.behavior;

import org.uqbarproject.sokoban.domain.behavior.Position;

public interface Movement {
	public void move(Position aPosition, int spaces);
}
