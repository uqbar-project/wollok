package org.uqbarproject.sokoban.domain.pieces;

import org.uqbarproject.sokoban.domain.behavior.Movement;

public class Wall extends Element{

	public Wall(){
		this.setImageName("muro.png");
	}
	@Override
	public boolean mayIMove(Movement aMovement, int places) {
		return false;
	}

	@Override
	public boolean iAmSolid() {
		return true;
	}

}
