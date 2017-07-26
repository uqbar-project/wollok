package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.draw2d.Graphics
import org.eclipse.draw2d.IFigure
import org.eclipse.draw2d.MarginBorder
import org.eclipse.draw2d.geometry.Insets

/**
 * @author jfernandes
 */
class WSeparatorBorder extends MarginBorder {
	static int TOP_PADDING = 5
	static int LEFT_PADDING = 3
	static int BOTTOM_PADDING = 5
	static int RIGHT_PADDING = 1

	new() {
		super(TOP_PADDING, LEFT_PADDING, BOTTOM_PADDING, RIGHT_PADDING)
	}

	override paint(IFigure figure, Graphics graphics, Insets insets) {
		val rec = getPaintRectangle(figure, insets)
		graphics.foregroundColor = ClassDiagramColors.CLASS_INNER_BORDER
		graphics.drawLine(rec.x, rec.y, rec.right(), rec.y)
	}

}
