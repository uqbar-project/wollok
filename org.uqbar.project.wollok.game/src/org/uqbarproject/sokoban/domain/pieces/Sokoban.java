package org.uqbarproject.sokoban.domain.pieces;

import org.uqbarproject.sokoban.domain.behavior.Movement;

public class Sokoban extends Element{

	public Sokoban() {
		this.setImageName("jugador.png");
	}
	@Override
	public boolean mayIMove(Movement aMovement, int places) {
		return true;
	}

	@Override
	public boolean iAmSolid() {
		return true;
	}
	@Override
	public void setMyGameBoard(GameBoard myGameBoard) {
		this.myGameBoard = myGameBoard;
		//myGameBoard.addElement(this);
	}
}
