package org.uqbar.project.wollok.lib

import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static extension org.uqbar.project.wollok.lib.WollokConventionExtensions.*
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class WVisual extends VisualComponent {

	public WollokObject wObject
	WollokObject wPosition

	new(WollokObject object) {
		wObject = object
		wObject.position // Force evaluate position when is added
	}

	new(WollokObject object, WollokObject position) {
		wObject = object
		this.wPosition = position
	}

	override getAttributes() {
		wObject
		.printableVariables
		.filter[value !== null]
		.map[key + ":" + value.toString]
		.toList
	}
	
	override getImage() {
		new WImage(wObject.image)
	}

	override getPosition() {
		objectPosition
	}

	override setPosition(Position position) {
		wPosition = objectPosition.copyFrom(position) 
	}

	def getObjectPosition() {
		if (wPosition !== null)
			return new WPosition(wPosition)

		new WPosition(wObject.position)
	}
}
