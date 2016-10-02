package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.draw2d.Label
import org.eclipse.draw2d.PositionConstants
import org.eclipse.draw2d.TextUtilities
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.Rectangle
import org.uqbar.project.wollok.ui.WollokActivator

/**
 * Superclass for methods and instance variables figures
 * They share a couple of things :P
 * 
 * @author jfernandes
 */
abstract class AbstractClassMemberFigure<T> extends Label {
	protected val labelProvider = WollokActivator.getInstance.labelProvider
	protected val T member
	
	new(T member) {
		this.member = member
		
		text = doGetText
		icon = labelProvider.getImage(member)
		labelAlignment = PositionConstants.LEFT
		
		this.bounds = calculateSize 
	}
	
	 def Rectangle calculateSize() {
    	val size = TextUtilities.INSTANCE.getStringExtents(text, font);
    	new Rectangle(new Point(bounds.x, bounds.y), size)
  	}
	
	def doGetText() {
		labelProvider.getText(member)
	}
}