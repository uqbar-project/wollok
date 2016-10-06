package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer

/**
 * Preferences page for validator
 * 
 * @author jfernandes
 */
class ValidatorPreferencePage extends AbstractWollokPropertyAndPreferencePage {

	override pageID() { "validator" }
	
	override createBlock(IProject project, IPreferenceStore preferenceStore, IWorkbenchPreferenceContainer container) {
		new ValidatorConfigurationBlock(project, preferenceStore, container)
	}
	
}