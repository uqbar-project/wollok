package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.eclipse.draw2d.Label
import org.uqbar.project.wollok.ui.diagrams.classes.model.MixinModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.ClassDiagramColors
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure
import org.uqbar.project.wollok.wollokDsl.WMixin

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 */
class MixinEditPart extends AbstractMethodContainerEditPart {
	
	override MixinModel getCastedModel() { model as MixinModel }
	override WMixin getLanguageElement() { castedModel.component as WMixin }
	
	override protected createFigure() {
		new WClassFigure(castedModel.component.name, ClassDiagramColors.MIXIN_FOREGROUND, ClassDiagramColors.MIXIN_BACKGROUND, castedModel) => [ f |
//			f.abstract = castedModel.mixin.abstract
		]
	}

}