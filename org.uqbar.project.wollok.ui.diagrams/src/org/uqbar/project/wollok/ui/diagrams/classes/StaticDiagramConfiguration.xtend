package org.uqbar.project.wollok.ui.diagrams.classes

import java.util.Map
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

@Accessors
class StaticDiagramConfiguration {
	
	boolean showVariables
	Map<String, Point> locations
	Map<String, Dimension> sizes
	
	new() {
		println("*********************************************** INITIALIZATION ")
		locations = newHashMap
		sizes = newHashMap
	}
	
	def Point getLocation(Shape shape) {
		println("************************************************")
		println("Get location of " + shape.toString)
		println("Locations " + locations)
		println("Returns " + locations.get(shape.toString))
		println("************************************************")
		locations.get(shape.toString)
	}
	
	def void saveLocation(Shape shape) {
		println("************************************************")
		println("Save location of " + shape.toString)
		println("Locations " + locations)
		locations.put(shape.toString, new Point => [
			x = shape.location.x
			y = shape.location.y
		])
		println("Pointing to " + locations.get(shape.toString))
		println("************************************************")
				
	}

	def Dimension getSize(Shape shape) {
		sizes.get(shape.toString)
	}
	
	def void saveSize(Shape shape) {
		sizes.put(shape.toString, new Dimension => [
			height = shape.size.height
			width = shape.size.width
		])
	}
	
}

