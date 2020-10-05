package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer

class WollokConsolePreferencePage extends WollokAbstractPreferencePage {
	override buildConfigurationBlock(IProject project, IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		new WollokConsoleConfigurationBlock(project, store, container)
	}
	
	override getPageID() { "console" }
}
