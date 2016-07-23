package org.uqbar.project.wollok.ui.diagrams.classes.parts

import org.uqbar.project.wollok.ui.diagrams.classes.model.MixinModel
import org.uqbar.project.wollok.ui.diagrams.classes.view.ClassDiagramColors
import org.uqbar.project.wollok.ui.diagrams.classes.view.WClassFigure
import org.uqbar.project.wollok.wollokDsl.WMixin

/**
 * 
 * @author jfernandes
 */
class MixinEditPart extends AbstractMethodContainerEditPart {
	
	override MixinModel getCastedModel() { model as MixinModel }
	override getModelChildren() { languageElement.members }
	override WMixin getLanguageElement() { castedModel.mixin }
	
	override protected createFigure() {
		new WClassFigure(castedModel.mixin.name, ClassDiagramColors.MIXIN_FOREGROUND, ClassDiagramColors.MIXIN_BACKGROUND) => [ f |
//			f.abstract = castedModel.mixin.abstract
		]
	}

}