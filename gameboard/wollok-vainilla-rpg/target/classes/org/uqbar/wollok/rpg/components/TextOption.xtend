package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.GameComponent
import com.uqbar.vainilla.appearances.Label
import java.awt.Color
import java.awt.Font

/**
 * 
 */
class TextOption extends GameComponent {
	
	new(int x, int y, String text) {
		super(x, y)
		appearance = new Label(new Font("SansSerif", Font.PLAIN, 18), Color.WHITE, text)
	}
	
}