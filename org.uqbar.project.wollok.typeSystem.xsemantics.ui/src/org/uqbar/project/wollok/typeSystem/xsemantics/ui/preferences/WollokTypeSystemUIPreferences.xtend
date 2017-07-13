package org.uqbar.project.wollok.typeSystem.xsemantics.ui.preferences

import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.typesystem.preferences.WollokTypeSystemPreference

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokTypeSystemUIPreferences implements WollokTypeSystemPreference {
	public static val PREF_TYPE_SYSTEM_IMPL = "TYPE_SYSTEM_IMPL"
	public static val PREF_TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED"

	@Inject IPreferenceStoreAccess preferenceStoreAccess

	override isTypeSystemEnabled(EObject file) {
		file.preferences.getBoolean(PREF_TYPE_SYSTEM_CHECKS_ENABLED)
	}

	override getSelectedTypeSystem(EObject file) {
		var selectedTypeSystem = file.preferences.getString(PREF_TYPE_SYSTEM_IMPL)
		if(selectedTypeSystem === null || selectedTypeSystem == "")
			selectedTypeSystem = "Constraints-based";
		
		selectedTypeSystem
	}

	def preferences(EObject obj) {
		preferenceStoreAccess.getContextPreferenceStore(obj.IFile.project)
	}
}
