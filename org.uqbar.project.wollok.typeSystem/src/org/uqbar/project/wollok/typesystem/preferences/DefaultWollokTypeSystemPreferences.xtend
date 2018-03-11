package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.core.resources.IProject

class DefaultWollokTypeSystemPreferences implements WollokTypeSystemPreference {
	
	override isTypeSystemEnabled(IProject project) {
		false
	}
	
	override getSelectedTypeSystem(IProject project) {
		"Constraints-based"
	}
	
}