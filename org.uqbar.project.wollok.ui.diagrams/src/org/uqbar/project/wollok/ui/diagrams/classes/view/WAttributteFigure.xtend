package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.draw2d.Label
import org.eclipse.draw2d.PositionConstants
import org.eclipse.jface.resource.JFaceResources

/**
 * 
 * @author jfernandes
 */
class WAttributteFigure extends Label {
	
	new(String text) {
		this.text = text
		labelAlignment = PositionConstants.LEFT
	}

	def setLineItalic(String text, boolean italic) {
		font = if (italic)
			JFaceResources.fontRegistry.getItalic(JFaceResources.TEXT_FONT)
		else
			JFaceResources.fontRegistry.get(JFaceResources.DEFAULT_FONT)
		repaint
	}
	
	
}