package org.uqbar.project.wollok.ui.diagrams.classes.model;

import java.beans.PropertyChangeListener;
import java.beans.PropertyChangeSupport;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.Serializable;

import org.eclipse.ui.views.properties.IPropertyDescriptor;
import org.eclipse.ui.views.properties.IPropertySource;

/**
 * 
 * Abstract class for a model element in the static diagram.
 * 
 * @author jfernandes
 */
abstract class ModelElement implements IPropertySource, Serializable {
	private static final IPropertyDescriptor[] EMPTY_ARRAY = newArrayOfSize(0)
	private transient PropertyChangeSupport pcsDelegate = new PropertyChangeSupport(this)

	def synchronized void addPropertyChangeListener(PropertyChangeListener l) {
		if (l == null)
			throw new IllegalArgumentException
		pcsDelegate.addPropertyChangeListener(l);
	}

	def firePropertyChange(String property, Object oldValue, Object newValue) {
		if (pcsDelegate.hasListeners(property))
			pcsDelegate.firePropertyChange(property, oldValue, newValue);
	}

	override getEditableValue() {
		this
	}

	override getPropertyDescriptors() {
		EMPTY_ARRAY
	}

	override getPropertyValue(Object id) {
		null
	}

	override isPropertySet(Object id) {
		false
	}

	def readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
		in.defaultReadObject
		pcsDelegate = new PropertyChangeSupport(this);
	}

	def synchronized void removePropertyChangeListener(PropertyChangeListener l) {
		if (l != null)
			pcsDelegate.removePropertyChangeListener(l)
	}

	override resetPropertyValue(Object id) {
		// do nothing
	}

	override setPropertyValue(Object id, Object value) {
		// do nothing
	}
}
