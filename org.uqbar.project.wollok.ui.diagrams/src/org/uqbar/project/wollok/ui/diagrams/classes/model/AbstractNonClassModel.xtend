package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.eclipse.draw2d.geometry.Point
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

class AbstractNonClassModel extends AbstractModel {
	
	new(WMethodContainer mc) {
		super(mc)
	}
	
	def void locate() {
		location = configuration.getLocation(this) ?: new Point(XPosition, INITIAL_MARGIN)
	}

	def int getXPosition() {
		val allWidths = elements
			.clone
			.filter [ !it.equals(this) ]
			.fold(0, [acum, object |
				acum + object.size.width
			])
		INITIAL_MARGIN + (elements.size * WIDTH_SEPARATION_BETWEEN_ELEMENTS) + allWidths
	}
	
	override toString() {
		this.class.name + "<" + this.name + ">"		
	}
	
}