package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.draw2d.Label
import org.eclipse.draw2d.PositionConstants
import org.eclipse.jface.resource.JFaceResources

/**
 * @author jfernandes
 */
class WMethodFigure extends Label {
	
	new(String text) {
		this.text = text

//		icon = ...
		labelAlignment = PositionConstants.LEFT
	}

	def setAbstract(boolean isAbstract) {
		font = if (isAbstract)
				JFaceResources.fontRegistry.getItalic(JFaceResources.TEXT_FONT)
			else
				JFaceResources.fontRegistry.get(JFaceResources.DEFAULT_FONT)
		repaint
	}

}