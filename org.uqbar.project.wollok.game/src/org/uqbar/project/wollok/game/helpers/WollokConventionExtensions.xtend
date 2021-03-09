package org.uqbar.project.wollok.game.helpers

import com.badlogic.gdx.graphics.Color
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.VisualComponentWithPosition
import org.uqbar.project.wollok.interpreter.core.WollokObject

class WollokConventionExtensions {
		
	public static val POSITION_CONVENTION = "position"
	public static val TEXT_CONVENTION = "text"
	public static val TEXT_COLOR_CONVENTION = "textColor"
	public static val IMAGE_CONVENTION = "image"
	public static val DEFAULT_IMAGE = "wko.png"
	public static val DEFAULT_TEXT_COLOR = Color.BLUE
	public static val ALL_CONVENTIONS = #[POSITION_CONVENTION, IMAGE_CONVENTION, TEXT_CONVENTION, TEXT_COLOR_CONVENTION ]
	

	def static asVisual(WollokObject it) {
		position // Force evaluate position or MDU error
		new VisualComponent(it)
	}
	def static asVisualIn(WollokObject it, WollokObject position) { new VisualComponentWithPosition(it, position) }


	
	def static setPosition(WollokObject it, WollokObject position) {
		call(POSITION_CONVENTION, position)	
	}
	

	def static getPosition(WollokObject it) {
		call(POSITION_CONVENTION)	
	}

	def static getImage(WollokObject it) {
		call(IMAGE_CONVENTION)
	}
	
	def static getPrintableVariables(WollokObject it) {
		instanceVariables.entrySet.filter[key.printableVariable]
	}
		
	def static isConvention(String it) {
		ALL_CONVENTIONS.toList.contains(it)
	}
	
	def static isPrintableVariable(String it) {
		!it.isConvention && !it.startsWith("_")
	}
}
		