package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.Property

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
	
	def addNamedObject(NamedObjectModel s) {
		if (s != null && objects.add(s))
			firePropertyChange(CHILD_ADDED_PROP, null, s)
	}
	
	def connectRelations() {
		classes.forEach[c|
			val parent = c.clazz.parent
			if (parent != null) {
				val parentModel = classes.findFirst[clazz == parent]
				new Connection(null, c, parentModel)
			}
		]
	}

	def getChildren() {
		(classes + objects).toList
	}

	def removeChild(Shape s) {
		if (s != null && classes.remove(s))
			firePropertyChange(CHILD_REMOVED_PROP, null, s);
	}
}