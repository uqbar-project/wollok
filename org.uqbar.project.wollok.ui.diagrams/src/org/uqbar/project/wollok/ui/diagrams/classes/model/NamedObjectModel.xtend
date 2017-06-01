package org.uqbar.project.wollok.ui.diagrams.classes.model

import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * Rectangular Figure modeling a wko
 * 
 * @author jfernandes
 * @author dodain
 */
class NamedObjectModel extends AbstractNonClassModel {

	new(WNamedObject obj) {
		super(obj as WMethodContainer)
		objects.add(this)
	}

	override shouldShowConnectorTo(WClass clazz) {
		component.hasRealParent
	}
	
}
