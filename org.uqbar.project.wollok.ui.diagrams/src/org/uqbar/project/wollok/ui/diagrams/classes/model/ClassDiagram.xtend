package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.ArrayList
import java.util.List
import org.eclipse.draw2d.geometry.Point
import org.eclipse.xtend.lib.Property
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * 
 * @author jfernandes
 */
class ClassDiagram extends ModelElement {
	public static val CHILD_REMOVED_PROP = "ShapesDiagram.ChildRemoved"
	public static val CHILD_ADDED_PROP = "ShapesDiagram.ChildAdded"
	@Property List<ClassModel> classes = new ArrayList
	@Property List<NamedObjectModel> objects = new ArrayList

	def addClass(ClassModel s) {
		if (s != null && classes.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def addClass(WClass c) {
		addClass(new ClassModel(c) => [
			location = new Point(100, 100)
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
		if (parent != null) {
			val parentModel = classes.findFirst[clazz == parent]
			if (parentModel == null) {
				throw new WollokRuntimeException("Could NOT find diagram node for parent class " + parent.fqn)
//				addClass(parent)
			}
			else
				new Connection(null, it, parentModel)
		}
	}
	
	

	def getChildren() {
		(classes + objects).toList
	}

	def removeChild(Shape s) {
		if (s != null && classes.remove(s))
			firePropertyChange(CHILD_REMOVED_PROP, null, s);
	}
}