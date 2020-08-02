package org.uqbar.project.wollok.ui.diagrams.dynamic.configuration

import java.util.List
import org.eclipse.debug.core.model.IVariable
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.debugger.model.WollokVariable
import org.uqbar.project.wollok.ui.diagrams.classes.AbstractDiagramConfiguration
import org.uqbar.project.wollok.ui.diagrams.dynamic.parts.VariableModel
import org.uqbar.project.wollok.debugger.server.rmi.XDebugStackFrameVariable

@Accessors
class DynamicDiagramConfiguration extends AbstractDiagramConfiguration {

	public static String HIDDEN_OBJECTS_CHANGED = "hiddenObjects"
	
	static DynamicDiagramConfiguration instance
	
	static def getInstance() {
		if (instance === null) {
			instance = new DynamicDiagramConfiguration
		}
		instance
	}
	
	/**
	 * ********************************************************************
	 * CONFIGURATION ATTRIBUTES
	 * ********************************************************************
	 */
	boolean colorBlindEnabled = false
	boolean firstTimeRefreshView = false

	boolean hasEffectTransition = true
	int effectTransitionDelay = 500   // TODO: configure 250, 500, 1000, 2000
	List<String> hiddenObjects = newArrayList
	
	/**
	 * *********************************************************************
	 * PUBLIC INTERFACE
	 * *********************************************************************
	 */
	
	def hideObject(VariableModel model) {
		this.hiddenObjects.add(model.variable.toString)
		this.setChanged
		this.notifyObservers(HIDDEN_OBJECTS_CHANGED)
	}

	def resetHiddenObjects() {
		this.hiddenObjects = newArrayList
		this.setChanged
		this.notifyObservers(HIDDEN_OBJECTS_CHANGED)
	}
	
	def dispatch shouldHide(XDebugStackFrameVariable variable) {
		this.hiddenObjects.contains(variable.identifier)
	}

	def dispatch shouldHide(WollokVariable variable) {
		this.hiddenObjects.contains(variable.toString)
	}

	def dispatch shouldHide(IVariable variable) { false }
	
	def hasHiddenObjects() {
		!this.hiddenObjects.isEmpty
	}

	def shouldAnimate() {
		this.hasEffectTransition && this.firstTimeRefreshView		
	}
}