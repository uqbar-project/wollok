package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.emf.ecore.EObject
import org.eclipse.core.resources.IProject

class DefaultWollokTypeSystemPreferences implements WollokTypeSystemPreference {
	
	override isTypeSystemEnabled(EObject project) {
		false
	}
	
	override getSelectedTypeSystem(EObject file) {
		CONSTRAINTS_BASED
	}
	
	override getSelectedTypeSystem(IProject project) {
		CONSTRAINTS_BASED
	}
	
	override isTypeSystemEnabled(IProject file) {
		false
	}
	
}