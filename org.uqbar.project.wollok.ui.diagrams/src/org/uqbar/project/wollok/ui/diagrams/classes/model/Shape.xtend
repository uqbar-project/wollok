package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.util.List
import org.eclipse.draw2d.geometry.Dimension
import org.eclipse.draw2d.geometry.Point
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.ui.views.properties.TextPropertyDescriptor
import org.uqbar.project.wollok.wollokDsl.WClass

/**
 * @author jfernandes
 */
public abstract class Shape extends ModelElement {
	public static val LOCATION_PROP = "Shape.Location";
	public static val SIZE_PROP = "Shape.Size";
	public static val SOURCE_CONNECTIONS_PROP = "Shape.SourceConn";
	public static val TARGET_CONNECTIONS_PROP = "Shape.TargetConn";
	static val HEIGHT_PROP = "Shape.Height";
	static val WIDTH_PROP = "Shape.Width";
	static val XPOS_PROP = "Shape.xPos";
	static val YPOS_PROP = "Shape.yPos";
	static List<TextPropertyDescriptor> descriptors;
	
	Point location = new Point(0, 0)
	Dimension size = new Dimension(100, 100)
	List<Connection> sourceConnections = newArrayList
	List<Connection> targetConnections = newArrayList

	def static getDescriptors() {
		if (descriptors != null)
			return descriptors
		
		descriptors = #[
			// id
			new TextPropertyDescriptor(XPOS_PROP, "X"),
			// description
			new TextPropertyDescriptor(YPOS_PROP, "Y"),
			new TextPropertyDescriptor(WIDTH_PROP, "Width"),
			new TextPropertyDescriptor(HEIGHT_PROP, "Height")
		]
		
		descriptors.forEach[TextPropertyDescriptor p|
			p.validator = [value | validate(value as String) ]
		]
		descriptors
	}
	
	def static validate(String value) {
		try 
			if (Integer.parseInt(value) >= 0)  null else "Value must be >=  0"
		catch (NumberFormatException exc)
			"Not a number"
	}

	def void addConnection(Connection conn) {
		if (conn == null || conn.source == conn.target)
			throw new IllegalArgumentException
		if (conn.source == this) {
			sourceConnections.add(conn)
			firePropertyChange(SOURCE_CONNECTIONS_PROP, null, conn)
		} else if (conn.target == this) {
			targetConnections.add(conn)
			firePropertyChange(TARGET_CONNECTIONS_PROP, null, conn)
		}
	}

	def getLocation() {
		location.getCopy
	}

	override getPropertyDescriptors() {
		descriptors
	}

	override getPropertyValue(Object propertyId) {
		switch (propertyId) {
			case XPOS_PROP: location.x.toString
			case YPOS_PROP: location.y.toString
			case HEIGHT_PROP: size.height.toString
			case WIDTH_PROP: size.width.toString
			default: super.getPropertyValue(propertyId)
		}
	}

	def getSize() {
		size.getCopy
	}

	def getSourceConnections() {
		sourceConnections.clone
	}

	def getTargetConnections() {
		targetConnections.clone
	}

	def removeConnection(Connection conn) {
		if (conn == null) {
			throw new IllegalArgumentException
		}
		if (conn.source == this) {
			sourceConnections -= conn
			firePropertyChange(SOURCE_CONNECTIONS_PROP, null, conn)
		} else if (conn.target == this) {
			targetConnections -= conn
			firePropertyChange(TARGET_CONNECTIONS_PROP, null, conn)
		}
	}

	def setLocation(Point newLocation) {
		if (newLocation == null) {
			throw new IllegalArgumentException
		}
		location.location = newLocation
		firePropertyChange(LOCATION_PROP, null, location)
	}

	override setPropertyValue(Object propertyId, Object value) {
		if (XPOS_PROP == propertyId) {
			val x = Integer.parseInt(value as String)
			setLocation(new Point(x, location.y))
		} else if (YPOS_PROP == propertyId) {
			val y = Integer.parseInt(value as String)
			setLocation(new Point(location.x, y))
		} else if (HEIGHT_PROP == propertyId) {
			val height = Integer.parseInt(value as String)
			setSize(new Dimension(size.width, height))
		} else if (WIDTH_PROP == propertyId) {
			val width = Integer.parseInt(value as String)
			size = new Dimension(width, size.height)
		} else {
			super.setPropertyValue(propertyId, value)
		}
	}

	def setSize(Dimension newSize) {
		if (newSize != null) {
			size.size = newSize
			firePropertyChange(SIZE_PROP, null, size)
		}
	}
	
	def getBounds() {
		new Rectangle(location, size)
	}
	
	def boolean shouldShowConnectorTo(WClass model) {
		true
	}
	
}