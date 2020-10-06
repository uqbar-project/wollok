package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer

class WollokNumbersPreferencePage extends WollokAbstractPreferencePage {

	override buildConfigurationBlock(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		new WollokNumbersConfigurationBlock(project, store, container)
	}
		
	override getPageID() {
		"numbers"
	}
	
}
