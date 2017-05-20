package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape
import java.util.Observable

@Accessors
class StaticDiagramConfiguration extends Observable implements Serializable {
	
	boolean showVariables = false
	boolean rememberLocationAndSizeShapes = true
	Map<String, Point> locations
	Map<String, Dimension> sizes
	
	new() {
		initLocationsAndSizes
	}
	
	def Point getLocation(Shape shape) {
		locations.get(shape.toString)
	}
	
	def void saveLocation(Shape shape) {
		if (!rememberLocationAndSizeShapes) return;
		locations.put(shape.toString, new Point => [
			x = shape.location.x
			y = shape.location.y
		])
	}

	def Dimension getSize(Shape shape) {
		sizes.get(shape.toString)
	}
	
	def void saveSize(Shape shape) {
		if (!rememberLocationAndSizeShapes) return;
		sizes.put(shape.toString, new Dimension => [
			height = shape.size.height
			width = shape.size.width
		])
	}
	
	def void initLocationsAndSizes() {
		locations = newHashMap
		sizes = newHashMap		
	}
	
	def copyFrom(StaticDiagramConfiguration configuration) {
		this.showVariables = configuration.showVariables
		this.rememberLocationAndSizeShapes = configuration.rememberLocationAndSizeShapes
		this.locations = configuration.locations
		this.sizes = configuration.sizes
		this.setChanged
		this.notifyObservers
	}
	
}
