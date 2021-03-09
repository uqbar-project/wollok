package org.uqbar.project.wollok.game.helpers

import com.badlogic.gdx.graphics.Color
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.VisualComponentWithPosition
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.*

class WollokConventionExtensions {
		
	public static val POSITION_CONVENTION = "position"
	public static val TEXT_CONVENTION = "text"
	public static val TEXT_COLOR_CONVENTION = "textColor"
	public static val IMAGE_CONVENTION = "image"
	public static val DEFAULT_IMAGE = "wko.png"
	public static val DEFAULT_TEXT_COLOR = Color.BLUE
	

	def static asVisual(WollokObject it) { new VisualComponent(it) }
	def static asVisualIn(WollokObject it, WollokObject position) { new VisualComponentWithPosition(it, position) }



	def static getAllConventions() {
		#[POSITION_CONVENTION, IMAGE_CONVENTION]
	}
	
	def static setPosition(WollokObject it, WollokObject position) {
		call("position", position)	
	}
	

	def static getPosition(WollokObject it) {
		call("position")	
	}

	def static getImage(WollokObject it) {
		try {
			call("image")				
		} catch (WollokProgramExceptionWrapper exception) {
			if (exception.messageNotUnderstood) //TODO: Check inverted logic (!)
				throw exception
			else
				DEFAULT_IMAGE.javaToWollok
		}
	}
	
	def static getPrintableVariables(WollokObject it) {
		instanceVariables.entrySet.filter[key.printableVariable]
	}
		
	def static isConvention(String it) {
		allConventions.toList.contains(it)
	}
	
	def static isPrintableVariable(String it) {
		!it.isConvention && !it.startsWith("_")
	}
}
		