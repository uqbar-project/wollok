package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.jface.resource.JFaceResources
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

/**
 * @author jfernandes
 */
class WMethodFigure extends AbstractClassMemberFigure<WMethodDeclaration> {
	
	new(WMethodDeclaration m) {
		super(m)
	}

	def setAbstract(boolean isAbstract) {
		font = if (isAbstract)
				JFaceResources.fontRegistry.getItalic(JFaceResources.DEFAULT_FONT)
			else
				JFaceResources.fontRegistry.get(JFaceResources.DEFAULT_FONT)
		repaint
	}

}