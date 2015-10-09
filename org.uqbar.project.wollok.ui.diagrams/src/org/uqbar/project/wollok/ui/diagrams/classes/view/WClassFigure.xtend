package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.draw2d.ColorConstants
import org.eclipse.draw2d.Figure
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.Label
import org.eclipse.draw2d.LineBorder
import org.eclipse.draw2d.ToolbarLayout
import org.eclipse.swt.graphics.Color

import static org.uqbar.project.wollok.ui.utils.GefUtils.*

/**
 * 
 * @author jfernandes
 */
class WClassFigure extends Figure {
	Label nameLabel
	Figure attributesFigure
	Figure methodsFigure

	new(String name, Color fgColor, Color bgColor) {
		super()

		layoutManager = new ToolbarLayout => [
			matchWidth =  true
			spacing = 5
		]
		
		backgroundColor = bgColor
		foregroundColor = fgColor

		nameLabel = new Label(name) => [
			border = margin(2, 2, 5, 2)
		]
		add(nameLabel)
		abstract = false
		
		attributesFigure = createCompartment 
		add(attributesFigure)
		
		methodsFigure = createCompartment
		add(methodsFigure)
		
		opaque = true
	}
	
	def createCompartment() {
		new Figure => [
			layoutManager = new ToolbarLayout => [
				minorAlignment = ToolbarLayout.ALIGN_TOPLEFT				
			]
			border = new WSeparatorBorder
			backgroundColor = this.backgroundColor.darker
			opaque = true
		]
	}
	
	def darker(Color it) {
		new Color(null, red - 10, green - 10, blue - 10)
	}

	def setName(String newName) {
		if (nameLabel == null) {
			nameLabel = new Label(newName)
			add(nameLabel)
		} else
			nameLabel.text = newName
	}

	def getName() {
		nameLabel.text
	}

	override add(IFigure figure, Object constraint, int index) { addChild(figure, constraint, index) }
	def dispatch addChild(WAttributteFigure figure, Object constraint, int index) { attributesFigure.add(figure, constraint, -1) }
	def dispatch addChild(WMethodFigure figure, Object constraint, int index) { methodsFigure.add(figure, constraint, -1) }
	def dispatch addChild(IFigure figure, Object constraint, int index) { super.add(figure, constraint, index) }

	override remove(IFigure figure) { removeChild(figure) }
	def dispatch removeChild(WAttributteFigure it) { attributesFigure.remove(it) }
	def dispatch removeChild(WMethodFigure it) { methodsFigure.remove(it) }
	def dispatch removeChild(IFigure it) { super.remove(it) }

	def getNameLabel() {
		nameLabel
	}
	
	def setAbstract(boolean isAbstract) {
		nameLabel.font = if (isAbstract)
			 ClassDiagramColors.ABSTRACT_CLASS_NAME_FONT
			else
			 ClassDiagramColors.CLASS_NAME_FONT
	}
	
	def setFigureProblem(boolean problem) {
		border = new LineBorder => [ 
			color = if (problem) ColorConstants.red else ColorConstants.black
		]
	}
	
}