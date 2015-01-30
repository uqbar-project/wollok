package com.uqbar.vainilla.events.constants;

import java.awt.event.MouseEvent;
import java.util.HashMap;
import java.util.Map;

public enum MouseButton {
	LEFT, MIDDLE, RIGHT, ANY;

	private static final Map<Integer, MouseButton> EQUIVALENCES = new HashMap<Integer, MouseButton>() {
		{
			this.put(MouseEvent.BUTTON1, LEFT);
			this.put(MouseEvent.BUTTON2, MIDDLE);
			this.put(MouseEvent.BUTTON3, RIGHT);
		}
	};

	// ****************************************************************
	// ** STATICS
	// ****************************************************************

	public static MouseButton fromMouseButtonCode(int code) {
		return EQUIVALENCES.get(code);
	}
}