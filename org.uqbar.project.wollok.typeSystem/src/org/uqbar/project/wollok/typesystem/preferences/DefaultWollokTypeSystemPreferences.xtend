package org.uqbar.project.wollok.typesystem.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.validation.CheckSeverity

class DefaultWollokTypeSystemPreferences implements WollokTypeSystemPreference {
	
	override isTypeSystemEnabled(EObject file) {
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
	
	override getTypeSystemSeverity() {
		CheckSeverity.ERROR
	}
	
}