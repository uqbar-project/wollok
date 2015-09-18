package org.uqbar.project.wollok.ui.diagrams.classes.model;

import org.eclipse.draw2d.Graphics
import org.eclipse.ui.views.properties.ComboBoxPropertyDescriptor
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.diagrams.objects.parts.VariableModel

/**
 * A connection between two distinct shapes.
 * 
 * @author jfernandes
 */
class Connection extends ModelElement {
	static final val SOLID_STR = "Solid"
	static val DASHED_STR = "Dashed"
	
	public static val LINESTYLE_PROP = "LineStyle"
	static val descriptors = #[
		new ComboBoxPropertyDescriptor(LINESTYLE_PROP, LINESTYLE_PROP, #[SOLID_STR, DASHED_STR])
	]

	boolean isConnected
	int lineStyle
	Shape source
	Shape target
	@Accessors String name

	new(String name, Shape source, Shape target) {
		this.name = name
		reconnect(source, target)
		this.lineStyle = calculateLineStyle()
	}
	
	def calculateLineStyle() {
		if (source instanceof VariableModel && (source as VariableModel).isList) Graphics.LINE_DASH else Graphics.LINE_SOLID
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