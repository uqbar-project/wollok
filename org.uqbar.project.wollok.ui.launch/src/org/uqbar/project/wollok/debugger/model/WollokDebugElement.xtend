package org.uqbar.project.wollok.debugger.model

import org.eclipse.core.runtime.PlatformObject
import org.eclipse.debug.core.DebugEvent
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.DebugPlugin
import org.eclipse.debug.core.model.IDebugElement
import org.uqbar.project.wollok.ui.launch.WollokLaunchConstants
import org.uqbar.project.wollok.debugger.WollokDebugTarget
import org.uqbar.project.wollok.ui.launch.Activator

import static org.uqbar.project.wollok.utils.WEclipseUtils.*

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*

/**
 * Abstract base class for all UI objects representing debug elements.
 * They all know the target object, launch and debug model identifier.
 * 
 * They implement adapting to IDebugElement
 * And provides some helper methods for triggering events and aborting debugging sessions.
 * 
 * @author jfernandes
 */
abstract class WollokDebugElement extends PlatformObject implements IDebugElement {
	protected WollokDebugTarget target
	
	new(WollokDebugTarget target) { this.target = target }
	
	override WollokDebugTarget getDebugTarget() { target }
	override getLaunch() { debugTarget.launch }
	override getModelIdentifier() { WollokLaunchConstants.ID_DEBUG_MODEL }
	
	override getAdapter(Class adapter) {
		if (adapter == IDebugElement)
			this
		else
			super.getAdapter(adapter)
	}
	
	// events
	
	def abort(String message, Throwable e) throws DebugException {
		throw new DebugException(errorStatus(Activator.PLUGIN_ID, DebugPlugin.INTERNAL_ERROR, message, e))
	}
	
	def abort(String message) throws DebugException { abort(message, null) }
	
	def fireCreationEvent() { fireEvent(DebugEvent.CREATE) }	
	def fireTerminateEvent() { fireEvent(DebugEvent.TERMINATE) }
	
	def fireResumeEvent(int detail) {
		// no sacar el this !
		this.fireEvent(DebugEvent.RESUME, detail)
	}

	def fireSuspendEvent(int detail) {
		this.fireEvent(DebugEvent.SUSPEND, detail)
	}

}