package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer
import org.eclipse.xtext.ui.preferences.OptionsConfigurationBlock

abstract class WollokAbstractConfigurationBlock extends OptionsConfigurationBlock {
	
	new(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		super(project, store, container)
	}
	
	override protected getBuildJob(IProject project) {}
	
	override protected getFullBuildDialogStrings(boolean workspaceSettings) {}
	
	override protected validateSettings(String changedKey, String oldValue, String newValue) {}
	
	override performApply() {
		// Hay que hacer esto para que no se rompa Xtext
		savePreferences
		true
	}
	
	override performOk() {
		// Hay que hacer esto para que no se rompa Xtext
		savePreferences
		true
	}
	
}