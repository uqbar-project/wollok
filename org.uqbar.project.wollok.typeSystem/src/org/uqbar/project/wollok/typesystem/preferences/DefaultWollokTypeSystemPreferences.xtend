package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.emf.ecore.EObject

class DefaultWollokTypeSystemPreferences implements WollokTypeSystemPreference {
	
	override isTypeSystemEnabled(EObject project) {
		false
	}
	
	override getSelectedTypeSystem(EObject file) {
		"Constraints-based"
	}
	
}