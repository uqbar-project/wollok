package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.GameComponent
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.vainilla.components.collision.Collidable
import org.uqbar.wollok.rpg.WollokObjectView
import resource.Resource

import static extension org.uqbar.vainilla.components.behavior.VainillaExtensions.*

/**
 * @author jfernandes
 */
class Gem extends GameComponent implements Collidable, WollokObjectView {
	@Property WollokObject model
	
	new(WollokObject obj) {
		model = obj
		val color = model.call("getColor")
		appearance = Resource.getSprite("gem_tiles_" + color + ".png").asAnimation(0.08, 18)
	}
	
	override collidesWith(Collidable other) {
	}
	
}