package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.ClassDiagramColors
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * @author jfernandes
 */
class ClassEditPart extends AbstractMethodContainerEditPart {
	
	override getModelChildren() { castedModel.clazz.members }

	override createFigure() {
		new WClassFigure(castedModel.clazz.name, ClassDiagramColors.CLASS_FOREGROUND, ClassDiagramColors.CLASS_BACKGROUND) => [ f |
			f.abstract = castedModel.clazz.abstract
		]
	}
	
	override getLanguageElement() { castedModel.clazz }
	
	override ClassModel getCastedModel() { model as ClassModel }
	
}