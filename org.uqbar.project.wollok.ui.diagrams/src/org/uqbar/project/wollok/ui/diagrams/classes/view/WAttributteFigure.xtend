package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.jface.resource.JFaceResources
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration

/**
 * 
 * @author jfernandes
 */
class WAttributteFigure extends AbstractClassMemberFigure<WVariableDeclaration> {
	
	new(WVariableDeclaration v) {
		super(v)
	}

	def setLineItalic(String text, boolean italic) {
		font = if (italic)
			JFaceResources.fontRegistry.getItalic(JFaceResources.TEXT_FONT)
		else
			JFaceResources.fontRegistry.get(JFaceResources.DEFAULT_FONT)
		repaint
	}
	
	override doGetText() {
		labelProvider.getText(member.variable)
	}
	
	
}