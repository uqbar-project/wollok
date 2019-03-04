package org.uqbar.project.wollok.ui.diagrams.classes.parts;

import org.uqbar.project.wollok.ui.diagrams.classes.model.ClassModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.ui.diagrams.classes.view.StaticDiagramColors

/**
 * 
 * Edit part for classes
 * 
 * @author jfernandes
 */
class ClassEditPart extends AbstractMethodContainerEditPart {
	
	override createFigure() {
		new WClassFigure(castedModel.name, castedModel.foregroundColor, castedModel.backgroundColor, castedModel) => [ f |
			f.abstract = castedModel.getComponent.abstract
		]
	}
	
	def foregroundColor(ClassModel c) {
		if (c.component.isWellKnownObject) return StaticDiagramColors.NAMED_OBJECTS_FOREGROUND 
		if (c.imported) {
			StaticDiagramColors.IMPORTED_CLASS_FOREGROUND			
		} else {
			StaticDiagramColors.CLASS_FOREGROUND	
		}
	}
	
	def backgroundColor(ClassModel c) {
		if (c.component.isWellKnownObject) return StaticDiagramColors.NAMED_OBJECTS__BACKGROUND
		if (c.imported) {
			StaticDiagramColors.IMPORTED_CLASS_BACKGROUND			
		} else {
			StaticDiagramColors.CLASS_BACKGROUND	
		}
	}

	override getLanguageElement() { castedModel.getComponent }
	
	override ClassModel getCastedModel() { model as ClassModel }
	
}