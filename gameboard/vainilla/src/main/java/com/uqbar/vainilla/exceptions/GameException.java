package com.uqbar.vainilla.exceptions;

public class GameException extends RuntimeException {

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public GameException(String description) {
		super(description);
	}
}