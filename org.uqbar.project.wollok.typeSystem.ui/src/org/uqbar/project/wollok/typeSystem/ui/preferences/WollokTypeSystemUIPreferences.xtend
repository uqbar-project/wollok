package org.uqbar.project.wollok.typeSystem.ui.preferences

import com.google.inject.Inject
import org.eclipse.core.resources.IProject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.typesystem.Constants
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.preferences.WollokTypeSystemPreference
import org.uqbar.project.wollok.validation.CheckSeverity

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokTypeSystemUIPreferences implements WollokTypeSystemPreference {
	public static val PREF_TYPE_SYSTEM_SEVERITY = "TYPE_SYSTEM_SEVERITY"
	public static val PREF_TYPE_SYSTEM_IMPL = "TYPE_SYSTEM_IMPL"
	public static val PREF_TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED"
	public static val severities = #[CheckSeverity.INFO, CheckSeverity.WARN, CheckSeverity.ERROR]

	static def severitiesDescriptions() {
		#[
			Messages.WollokTypeSystem_INFO_DESCRIPTION, 
		 	Messages.WollokTypeSystem_WARN_DESCRIPTION,
			Messages.WollokTypeSystem_ERROR_DESCRIPTION
		]	
	} 

	@Inject IPreferenceStoreAccess preferenceStoreAccess

	override isTypeSystemEnabled(EObject file) {
		file.preferences.getBoolean(PREF_TYPE_SYSTEM_CHECKS_ENABLED)
	}

	override getSelectedTypeSystem(EObject file) {
		var selectedTypeSystem = file.preferences.getString(PREF_TYPE_SYSTEM_IMPL)
		if (selectedTypeSystem === null || selectedTypeSystem == "")
			selectedTypeSystem = Constants.TS_CONSTRAINTS_BASED

		selectedTypeSystem
	}

	override isTypeSystemEnabled(IProject project) {
		project.preferences.getBoolean(PREF_TYPE_SYSTEM_CHECKS_ENABLED)
	}

	override getSelectedTypeSystem(IProject project) {
		var selectedTypeSystem = project.preferences.getString(PREF_TYPE_SYSTEM_IMPL)
		if (selectedTypeSystem === null || selectedTypeSystem == "")
			selectedTypeSystem = Constants.TS_CONSTRAINTS_BASED

		selectedTypeSystem
	}

	override getTypeSystemSeverity() {
		val severity = preferenceStoreAccess.preferenceStore.getString(PREF_TYPE_SYSTEM_SEVERITY)
		severities.findFirst[ toString.equalsIgnoreCase(severity) ]
	}
	
	def preferences(EObject obj) {
		preferenceStoreAccess.getContextPreferenceStore(obj.IFile.project)
	}

	def preferences(IProject project) {
		preferenceStoreAccess.getContextPreferenceStore(project)
	}
	
}
