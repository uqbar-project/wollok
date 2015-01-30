package org.uqbar.project.wollok.ui.debugger.model

import org.eclipse.core.resources.IMarker
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.model.IBreakpoint
import org.eclipse.debug.core.model.LineBreakpoint

import static org.uqbar.project.wollok.launch.WollokLaunchConstants.*
import org.uqbar.project.wollok.launch.WollokLaunchConstants

/**
 * 
 * @author jfernandes
 */
class WollokLineBreakpoint extends LineBreakpoint {
	
	// keep it for eclipse restoring
	new() {	}
	
	new(IResource resource, int lineNumber) throws CoreException {
		run(getMarkerRule(resource))[ monitor |
			setMarker(resource.createMarker(WollokLaunchConstants.LINE_BREAKPOINT_MARKER) => [
					setAttribute(IBreakpoint.ENABLED, Boolean.TRUE)
					setAttribute(IMarker.LINE_NUMBER, lineNumber)
					setAttribute(IBreakpoint.ID, modelIdentifier)
					setAttribute(IMarker.MESSAGE, resource.name + ":" + lineNumber)
			])
		]
	}
	
	override getModelIdentifier() { ID_DEBUG_MODEL }
	
	override toString() { marker.attributes.get(IMarker.MESSAGE).toString }
	
}