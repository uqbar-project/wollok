package org.uqbar.project.wollok.ui.diagrams.classes.parts

import java.beans.PropertyChangeListener
import org.eclipse.gef.ConnectionEditPart
import org.eclipse.gef.NodeEditPart
import org.uqbar.project.wollok.ui.diagrams.classes.anchors.NamedObjectWollokAnchor
import org.uqbar.project.wollok.ui.diagrams.classes.model.NamedObjectModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.ui.diagrams.classes.view.StaticDiagramColors

/**
 * Edit part for named objects nodes.
 * 
 * @author jfernandes
 */
class NamedObjectEditPart extends AbstractMethodContainerEditPart implements PropertyChangeListener, NodeEditPart {

	override NamedObjectModel getCastedModel() { model as NamedObjectModel }

	override WNamedObject getLanguageElement() { castedModel.component as WNamedObject }
	
	override createFigure() {
		new WClassFigure(languageElement.name, StaticDiagramColors.NAMED_OBJECTS_FOREGROUND, StaticDiagramColors.NAMED_OBJECTS__BACKGROUND, castedModel)
	}

	override mappedConnectionAnchor(ConnectionEditPart connection) {
		new NamedObjectWollokAnchor(figure)
	}
	
}