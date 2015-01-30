package org.uqbar.vainilla.components.collision

import com.uqbar.vainilla.colissions.Circle

/**
 * @author jfernandes
 */
interface Collidable {
	
	def void collidesWith(Collidable other)
	
	// debería ser más genérico y el engine de colisiones saber trabajar con cualquier Shape
	// por ahora corto acá
	def Circle getCirc()
	
}