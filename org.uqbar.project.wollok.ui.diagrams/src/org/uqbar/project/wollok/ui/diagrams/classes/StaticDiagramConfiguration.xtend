package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.Serializable
import java.util.List
import java.util.Map
import java.util.Observable
import org.eclipse.core.resources.IResource
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

@Accessors
class StaticDiagramConfiguration extends Observable implements Serializable {
	
	boolean showVariables = false
	boolean rememberLocationAndSizeShapes = true
	Map<String, Point> locations
	Map<String, Dimension> sizes
	List<String> hiddenComponents = newArrayList
	List<Association> associations = newArrayList
	String fileName = ""
	String project = ""
	
	new() {
		init
	}
	
	def void init() {
		initLocationsAndSizes
		initHiddenComponents
		initAssociations
	}
	
	def void initLocationsAndSizes() {
		locations = newHashMap
		sizes = newHashMap		
	}

	def void initHiddenComponents() {
		hiddenComponents = newArrayList
	}

	def void initAssociations() {
		associations = newArrayList
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
	
	def copyFrom(StaticDiagramConfiguration configuration) {
		this.showVariables = configuration.showVariables
		this.rememberLocationAndSizeShapes = configuration.rememberLocationAndSizeShapes
		this.locations = configuration.locations
		this.sizes = configuration.sizes
		this.hiddenComponents = configuration.hiddenComponents
		this.associations = configuration.associations
		this.fileName = configuration.fileName
		this.project = configuration.project
		this.setChanged
		this.notifyObservers
	}
	
	def deleteClass(AbstractModel model) {
		hiddenComponents.add(model.label)
	}
	
	def addAssociation(AbstractModel modelSource, AbstractModel modelTarget) {
		associations.add(new Association(modelSource.label, modelTarget.label))
		this.setChanged
		this.notifyObservers(associations)
	}

	def setResource(IResource resource) {
		this.project = resource.project.name
		val previousFileName = this.fileName
		this.fileName = resource.fullPath.lastSegment
		if (!this.fileName.equals(previousFileName)) {
			this.init
		}
		this.setChanged
		this.notifyObservers
	}
		
}
