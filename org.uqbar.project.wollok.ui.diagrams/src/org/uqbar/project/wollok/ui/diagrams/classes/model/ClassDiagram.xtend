package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 */
@Accessors
class ClassDiagram extends ModelElement {
	public static val CHILD_REMOVED_PROP = "ShapesDiagram.ChildRemoved"
	public static val CHILD_ADDED_PROP = "ShapesDiagram.ChildAdded"
	List<ClassModel> classes = new ArrayList
	List<MixinModel> mixins = new ArrayList
	List<NamedObjectModel> objects = new ArrayList

	def addClass(ClassModel s) {
		if (s != null && classes.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def addClass(WClass c, int level) {
		addClass(new ClassModel(c) => [
			locate(level)
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
	
	def connectRelations() {
		classes.clone.forEach[createRelation(clazz)]
		objects.forEach[createRelation(obj)]
	}
	
	def createRelation(Shape it, WMethodContainer c) {
		val parent = c.parent
		if (parent != null && it.shouldShowConnectorTo(parent)) {
			val parentModel = classes.findFirst[clazz == parent]
			if (parentModel == null) {
				throw new WollokRuntimeException("Could NOT find diagram node for parent class " + parent.fqn)
			}
			else {
				new Connection(null, it, parentModel)
			}
		}
		// mixins
		c.mixins.forEach[m |
			val mixinEditPart = mixins.findFirst[ mixin == m ]
			new Connection(null, it, mixinEditPart)
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