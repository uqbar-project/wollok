package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import java.util.Map
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

@Accessors
class StaticDiagramConfiguration implements Serializable {
	
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
	
}

