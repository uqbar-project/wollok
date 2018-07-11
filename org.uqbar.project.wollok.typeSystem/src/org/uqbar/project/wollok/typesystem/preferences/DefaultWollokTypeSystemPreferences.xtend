package org.uqbar.project.wollok.typesystem.preferences

import org.uqbar.project.wollok.typesystem.preferences.WollokTypeSystemPreference
import org.eclipse.emf.ecore.EObject

class DefaultWollokTypeSystemPreferences implements WollokTypeSystemPreference {
	
	override isTypeSystemEnabled(EObject file) {
		false
	}
	
	override getSelectedTypeSystem(EObject file) {
		"Constraints-based"
	}
	
}