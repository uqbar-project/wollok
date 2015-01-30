package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.GameComponent
import com.uqbar.vainilla.appearances.Animation
import com.uqbar.vainilla.appearances.Sprite
import com.uqbar.vainilla.colissions.Rectangle
import java.awt.Graphics2D
import java.awt.RenderingHints
import java.awt.geom.Point2D
import org.uqbar.vainilla.components.collision.Collidable
import org.uqbar.wollok.rpg.WollokMovingGameComponent

/**
 * @author jfernandes
 */
class VainillaExtensions {
	
	def static asAnimation(Sprite sprite, double meanTime, int amountOfFrames) {
		parseAnimation(sprite, 0, sprite.width as int / amountOfFrames, sprite.height as int, meanTime)
	}
	
	def static parseAnimation(Sprite tiles, int y, int tileWidth, int tileHeight, double meanTime) {
		val frames = newArrayList
		var x = 0
		while (x < tiles.width) {
			frames.add(tiles.crop(x, y, tileWidth, tileHeight))
			x += tileWidth
		}
		new Animation(meanTime, frames)
	}
	
	def static rightOf(GameComponent c) { c.x + c.width }
	def static collidingComponents(WollokMovingGameComponent c) { c.scene.collisions(c as Collidable) }
	
	def static antialiasingOn(Graphics2D g) {
		g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
		g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
	}
	
	def static contains(Rectangle rect, Point2D.Double p) {
		   p.x >= rect.x && p.x <= (rect.x + rect.width)
		&& p.y >= rect.y && p.y <= (rect.y + rect.height)
	}
}