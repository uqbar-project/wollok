package org.uqbarproject.sokoban.domain.pieces;

import org.uqbarproject.sokoban.domain.behavior.Movement;

public class Box extends Element{

	public Box(){
		this.setImageName("caja.png");
	}
	@Override
	public boolean mayIMove(Movement aMovement, int places) {
		return true && this.getMyGameBoard().mayIMove(this, aMovement, places);
	}

	@Override
	public boolean iAmSolid() {
		return true;
	}
}
