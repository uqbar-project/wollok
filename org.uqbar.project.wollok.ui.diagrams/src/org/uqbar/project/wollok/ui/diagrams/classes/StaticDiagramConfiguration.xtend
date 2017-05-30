package org.uqbar.project.wollok.ui.diagrams.classes

import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.io.Serializable
import java.util.List
import java.util.Map
import java.util.Observable
import org.eclipse.core.resources.IResource
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.Messages
import org.uqbar.project.wollok.ui.diagrams.classes.model.AbstractModel
import org.uqbar.project.wollok.ui.diagrams.classes.model.RelationType
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

/**
 * @author dodain
 * 
 * Responsible for storing configuration of a static diagram
 * It is a singleton, so it is refreshed when you change xtext document (@see setResource)
 *  
 */
@Accessors
class StaticDiagramConfiguration extends Observable implements Serializable {

	/** Notification Events  */
	public static String CONFIGURATION_CHANGED = "configuration"
	
	/** Internal state */	
	boolean showVariables = false
	boolean rememberLocationAndSizeShapes = true
	Map<String, Point> locations
	Map<String, Dimension> sizes
	List<String> hiddenComponents = newArrayList
	List<Relation> relations = newArrayList
	String originalFileName = ""
	String fullPath = ""
	
	new() {
		init
	}
	
	/** 
	 ******************************************************
	 *  STATE INITIALIZATION 
	 *******************************************************
	 */	
	def void init() {
		internalInitLocationsAndSizes
		internalInitHiddenComponents
		internalInitRelationships
	}
	
	def void initLocationsAndSizes() {
		this.internalInitLocationsAndSizes
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def void internalInitLocationsAndSizes() {
		locations = newHashMap
		sizes = newHashMap
	}

	def void showAllComponents() {
		this.internalInitHiddenComponents
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def void internalInitHiddenComponents() {
		hiddenComponents = newArrayList
	}

	def void initRelationships() {
		this.internalInitRelationships
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}	
	
	def void internalInitRelationships() {
		relations = newArrayList
	}
	
	/** 
	 * 
	 ******************************************************
	 *  CONFIGURATION CHANGES 
	 *******************************************************
	 */	
	def void saveLocation(Shape shape) {
		if (!rememberLocationAndSizeShapes) return;
		locations.put(shape.toString, new Point => [
			x = shape.location.x
			y = shape.location.y
		])
		this.setChanged
	}

	def void saveSize(Shape shape) {
		if (!rememberLocationAndSizeShapes) return;
		sizes.put(shape.toString, new Dimension => [
			height = shape.size.height
			width = shape.size.width
		])
		this.setChanged
	}
	
	def hideComponent(AbstractModel model) {
		hiddenComponents.add(model.label)
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def addAssociation(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.add(new Relation(modelSource.label, modelTarget.label, RelationType.ASSOCIATION))
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	def removeAssociation(AbstractModel modelSource, AbstractModel modelTarget) {
		val element = this.findAssociationBetween(modelSource, modelTarget)
		if (element === null) {
			throw new RuntimeException(NLS.bind(Messages.StaticDiagram_Association_Not_Found, modelSource.name, modelTarget.name))
		}
		relations.remove(element)
		this.setChanged
	}
	
	def findAssociationBetween(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.findFirst [ it.source.equals(modelSource.label) && it.target.equals(modelTarget.label) && it.relationType == RelationType.ASSOCIATION ]
	}

	def removeDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		val element = relations.findFirst [ it.source.equals(modelSource.label) && it.target.equals(modelTarget.label) && it.relationType == RelationType.DEPENDENCY ]
		if (element === null) {
			throw new RuntimeException(NLS.bind(Messages.StaticDiagram_Dependency_Not_Found, modelSource.name, modelTarget.name))
		}
		relations.remove(element)
		this.setChanged

	}

	def addDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		relations.add(new Relation(modelSource.label, modelTarget.label, RelationType.DEPENDENCY))
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def canAddDependency(AbstractModel modelSource, AbstractModel modelTarget) {
		modelSource !== modelTarget && this.findAssociationBetween(modelSource, modelTarget) === null
	}

	def void setShowVariables(boolean show) {
		this.showVariables = show
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def void setRememberLocationAndSizeShapes(boolean remember) {
		this.rememberLocationAndSizeShapes = remember
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	/** 
	 * Fired each time you click on a xtext document
	 * If resource changed, configuration should clean up its state
	 */
	def setResource(IResource resource) {
		val previousFileName = this.originalFileName
		if (resource.project.locationURI !== null) {
			this.fullPath = resource.project.locationURI.rawPath + File.separator + WollokConstants.DIAGRAMS_FOLDER
			this.originalFileName = resource.location.lastSegment
		} else {
			// it is a platform file
			this.fullPath = WollokConstants.DIAGRAMS_FOLDER
			this.originalFileName = resource.name
		}
		// Starting from project/source folder,
		// and discarding file name (like objects.wlk) 
		//     we try to recreate same folder structure
		this.createDiagramsFolderIfNotExists(this.fullPath)
		resource.fullPath.removeFirstSegments(2).removeLastSegments(1).segments.toList.forEach [ segment |
			this.fullPath += File.separator + segment
			this.createDiagramsFolderIfNotExists(this.fullPath)	
		] 
		if (!this.originalFileName.equals(previousFileName)) {
			this.init
			this.loadConfiguration
		}
		this.setChanged
		this.notifyObservers(CONFIGURATION_CHANGED)
	}
	
	override protected setChanged() {
		super.setChanged()
		this.saveConfiguration()
	}

	/** 
	 ******************************************************
	 *  PUBLIC STATE & COPY METHODS 
	 *******************************************************
	 */	
	def Point getLocation(Shape shape) {
		locations.get(shape.toString)
	}
	
	def Dimension getSize(Shape shape) {
		sizes.get(shape.toString)
	}
	
	def copyFrom(StaticDiagramConfiguration configuration) {
		this.showVariables = configuration.showVariables
		this.rememberLocationAndSizeShapes = configuration.rememberLocationAndSizeShapes
		this.locations = configuration.locations
		this.sizes = configuration.sizes
		this.hiddenComponents = configuration.hiddenComponents
		this.relations = configuration.relations
		this.notifyObservers(CONFIGURATION_CHANGED)
	}

	def isHiddenComponent(String componentName) {
		this.hiddenComponents.contains(componentName)
	}

	/** 
	 ******************************************************
	 *  CONFIGURATION LOAD & SAVE TO EXTERNAL FILE 
	 *******************************************************
	 */	
	def void loadConfiguration() {
		if (this.resourceCanBeUsed) {
			try {
				val file = new FileInputStream(staticDiagramFullName)
				val ois = new ObjectInputStream(file)
				val newConfiguration = ois.readObject as StaticDiagramConfiguration
				this.copyFrom(newConfiguration)
			} catch (FileNotFoundException e) {
				println("Initializing file " + staticDiagramFullName)
				// nothing to worry, it will be saved afterwards
			}
		}
	}
	
	def void saveConfiguration() {
		if (this.resourceCanBeUsed) {
			val file = new FileOutputStream(staticDiagramFullName)
			val oos = new ObjectOutputStream(file)
			oos.writeObject(this)
		}
		
	}

	def getStaticDiagramFullName() {
		fullPath + File.separator + staticDiagramFileName
	}
	
	def getStaticDiagramFileName() {
		originalFileName.replace(WollokConstants.CLASS_OBJECTS_EXTENSION, WollokConstants.STATIC_DIAGRAM_EXTENSION)
	}
	
	def resourceCanBeUsed() {
		fullPath !== null && !fullPath.equals("") && originalFileName !== null && !originalFileName.equals("") && originalFileName.endsWith(WollokConstants.CLASS_OBJECTS_EXTENSION)
	}

	/** 
	 ******************************************************
	 *  SMART STRING PRINTING 
	 *******************************************************
	 */	
	override toString() {
		val result = new StringBuffer() => [
			append("Static Diagram {")
			append("\n")
			append("    relations = ")
			append(this.relations)
			append("\n")
			append("    hidden components = ")
			append(this.hiddenComponents)
			append("\n")
			append("    full path = ")
			append(this.fullPath)
			append("\n")
			append("    original file name = ")
			append(this.originalFileName)
			append("\n")
			append("    show variables = ")
			append(this.showVariables)
			append("\n")
			append("    remember locations = ")
			append(this.rememberLocationAndSizeShapes)
			append("\n")
			append("    locations = ")
			append(this.locations)
			append("\n")
			append("    sizes = ")
			append(this.sizes)
			append("\n")
			append("}")	
		]
		result.toString
	}


	/** 
	 ******************************************************
	 *  INTERNAL METHODS 
	 *******************************************************
	 */	
	def createDiagramsFolderIfNotExists(String folder) {
		val directory = new File(folder)
		if (!directory.exists) {
			directory.mkdir			
		}
	}
	
}
