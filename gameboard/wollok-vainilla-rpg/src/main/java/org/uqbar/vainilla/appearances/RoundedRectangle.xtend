package org.uqbar.vainilla.appearances

import com.uqbar.vainilla.GameComponent
import com.uqbar.vainilla.appearances.Rectangle
import java.awt.Color
import java.awt.Graphics2D

/**
 * 
 * @author jfernandes
 */
class RoundedRectangle extends Rectangle {
	int arcWidth
	int arcHeight
	
	new(Color color, int width, int height, int arcWidthAndHeight) {
		this(color, width, height, arcWidthAndHeight, arcWidthAndHeight)
	}
	
	new(Color color, int width, int height, int arcWidth, int arcHeight) {
		super(color, width, height)
		this.arcWidth = arcWidth
		this.arcHeight = arcHeight
	}

	override render(GameComponent<?> component, Graphics2D graphics) {
		graphics.color = color
		graphics.fillRoundRect(component.getX() as int, component.getY() as int, width as int, height as int, arcWidth, arcHeight)
	}	
	
}