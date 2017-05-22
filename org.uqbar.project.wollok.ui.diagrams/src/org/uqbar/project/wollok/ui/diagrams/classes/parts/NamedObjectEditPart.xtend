package org.uqbar.project.wollok.ui.diagrams.classes.parts

import java.beans.PropertyChangeListener
import org.eclipse.gef.NodeEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.NamedObjectWollokAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.model.NamedObjectModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.ClassDiagramColors
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure
import org.uqbar.project.wollok.wollokDsl.WNamedObject

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * Edit part for named objects nodes.
 * 
 * @author jfernandes
 */
class NamedObjectEditPart extends AbstractMethodContainerEditPart implements PropertyChangeListener, NodeEditPart {

	override NamedObjectModel getCastedModel() { model as NamedObjectModel }
	override doGetModelChildren() {
		if (castedModel.configuration.showVariables) castedModel.obj.members else castedModel.obj.methods.toList 
	}
	override WNamedObject getLanguageElement() { castedModel.obj }
	
	override createFigure() {
		new WClassFigure(languageElement.name, ClassDiagramColors.NAMED_OBJECTS_FOREGROUND, ClassDiagramColors.NAMED_OBJECTS__BACKGROUND)
	}

	override createConnectionAnchor() {
		new NamedObjectWollokAnchor(figure)
	}
	
}