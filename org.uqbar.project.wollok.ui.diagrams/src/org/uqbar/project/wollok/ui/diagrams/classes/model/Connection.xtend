package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.eclipse.draw2d.Graphics
import org.eclipse.ui.views.properties.ComboBoxPropertyDescriptor

/**
 * A connection between two distinct shapes.
 * 
 * @author jfernandes
 */
class Connection extends ModelElement {
	public static val SOLID_CONNECTION = new Integer(Graphics.LINE_SOLID)
	static final val SOLID_STR = "Solid"

	public static val DASHED_CONNECTION = new Integer(Graphics.LINE_DASH)
	static val DASHED_STR = "Dashed"
	
	public static val LINESTYLE_PROP = "LineStyle"
	static val descriptors = #[
		new ComboBoxPropertyDescriptor(LINESTYLE_PROP, LINESTYLE_PROP, #[SOLID_STR, DASHED_STR])
	]

	boolean isConnected
	int lineStyle = Graphics.LINE_SOLID
	Shape source
	Shape target

	new(Shape source, Shape target) {
		reconnect(source, target)
	}

	def disconnect() {
		if (isConnected) {
			source.removeConnection(this)
			target.removeConnection(this)
			isConnected = false
		}
	}

	def getLineStyle() {
		lineStyle
	}

	override getPropertyDescriptors() {
		descriptors
	}

	override getPropertyValue(Object id) {
		if (id == LINESTYLE_PROP) {
			if (lineStyle == Graphics.LINE_DASH)
				1 // dashed
			else
				0 // solid
		}
		else
			super.getPropertyValue(id)
	}

	def getSource() {
		source
	}

	def getTarget() {
		target
	}

	def reconnect() {
		if (!isConnected) {
			source.addConnection(this)
			target.addConnection(this)
			isConnected = true
		}
	}

	def reconnect(Shape newSource, Shape newTarget) {
		if (newSource == null || newTarget == null || newSource == newTarget) {
			throw new IllegalArgumentException
		}
		disconnect
		this.source = newSource
		this.target = newTarget
		reconnect
	}

	def setLineStyle(int lineStyle) {
		if (lineStyle != Graphics.LINE_DASH && lineStyle != Graphics.LINE_SOLID)
			throw new IllegalArgumentException
		this.lineStyle = lineStyle
		firePropertyChange(LINESTYLE_PROP, null, this.lineStyle)
	}

	override setPropertyValue(Object id, Object value) {
		if (id == LINESTYLE_PROP)
			lineStyle = if (1 == value) Graphics.LINE_DASH else Graphics.LINE_SOLID
		else
			super.setPropertyValue(id, value)
	}

}