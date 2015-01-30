package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.GameComponent
import java.awt.Color
import org.uqbar.vainilla.appearances.RoundedRectangle

/**
 * @author jfernandes
 */
//TODO: esto debería ser un composite component
class CollisionBubble extends GameComponent {
	
	new(int x, int y, int width, int height) {
		super(x, y)
		appearance = new RoundedRectangle(new Color(0,0, 225,180), width, height, 10)
	}
}