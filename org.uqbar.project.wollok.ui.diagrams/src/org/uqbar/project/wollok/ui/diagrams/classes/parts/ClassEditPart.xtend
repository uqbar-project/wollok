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
	
	override createFigure() {
		new WClassFigure(castedModel.name, castedModel.foregroundColor, castedModel.backgroundColor) => [ f |
			f.abstract = castedModel.clazz.abstract
		]
	}
	
	def foregroundColor(ClassModel c) {
		if (c.imported) {
			ClassDiagramColors.IMPORTED_CLASS_FOREGROUND			
		} else {
			ClassDiagramColors.CLASS_FOREGROUND	
		}
	}
	
	def backgroundColor(ClassModel c) {
		if (c.imported) {
			ClassDiagramColors.IMPORTED_CLASS_BACKGROUND			
		} else {
			ClassDiagramColors.CLASS_BACKGROUND	
		}
	}
	
	override getLanguageElement() { castedModel.clazz }
	
	override ClassModel getCastedModel() { model as ClassModel }
	
	override doGetModelChildren() {
		if (castedModel.configuration.showVariables) castedModel.clazz.members else castedModel.clazz.methods.toList
	}

}