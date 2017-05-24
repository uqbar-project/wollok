package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.diagrams.classes.StaticDiagramConfiguration
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamed

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 * 
 * http://www.programcreek.com/2013/03/eclipse-gef-tutorial/
 * 
 */
@Accessors
class StaticDiagram extends ModelElement {
	public static val CHILD_REMOVED_PROP = "ShapesDiagram.ChildRemoved"
	public static val CHILD_ADDED_PROP = "ShapesDiagram.ChildAdded"
	List<ClassModel> classes = new ArrayList
	List<? extends WNamed> importedObjects = new ArrayList
	List<MixinModel> mixins = new ArrayList
	List<NamedObjectModel> objects = new ArrayList
	StaticDiagramConfiguration configuration

	new(StaticDiagramConfiguration configuration) {
		this.configuration = configuration	
	}
	
	def addClass(ClassModel s) {
		if (s != null && classes.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def addComponent(WMethodContainer c, int level) {
		if (c == null || c.name == null) return;
		if (c.name.equals(WollokConstants.ROOT_CLASS)) return;
		addClass(new ClassModel(c) => [
			locate(level)
			if (importedObjects.map [ name ].contains(c.name)) {
				imported = true
			}
		])
	}
	
	def addMixin(MixinModel s) {
		if (s != null && mixins.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def addMixin(WMixin c) {
		addMixin(new MixinModel(c) => [
			locate
		])
	}
	
	def addNamedObject(NamedObjectModel s) {
		if (s != null && objects.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def connectInheritanceRelations() {
		classes.clone.forEach[createRelation(getComponent)]
		objects.forEach[createRelation(obj)]
	}
	
	def connectAssociationRelations() {
		configuration.associations.forEach [ association |
			val objects = children
			val sourceModel = objects.find(association.source)
			val targetModel = objects.find(association.target)
			if (sourceModel !== null && targetModel !== null) {
				new Connection(null, sourceModel, targetModel, RelationType.ASSOCIATION)
			} 
		]
	}
	
	def AbstractModel find(List<AbstractModel> models, String name) {
		children.findFirst [ label.equalsIgnoreCase(name) ]
	}
	
	def createRelation(Shape it, WMethodContainer c) {
		val parent = c.parent
		if (parent !== null && it.shouldShowConnectorTo(parent)) {
			val parentModel = classes.findFirst[getComponent == parent]
			if (parentModel === null) {
				//FED - just ignoring it, user may be editing it or it is object class
				//throw new WollokRuntimeException("Could NOT find diagram node for parent class " + parent.fqn)
			}
			else {
				new Connection(null, it, parentModel, RelationType.INHERITANCE)
			}
		}
		// mixins
		c.mixins.forEach[m |
			val mixinEditPart = mixins.findFirst[ mixin == m ]
			new Connection(null, it, mixinEditPart, RelationType.INHERITANCE)
		]
	}
	
	def getChildren() {
		(classes + objects + mixins).toList
	}

	def removeChild(Shape s) {
		if (s != null && classes.remove(s))
			firePropertyChange(CHILD_REMOVED_PROP, null, s);
	}
}