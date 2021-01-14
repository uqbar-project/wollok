package org.uqbar.project.wollok.ui.preferences

import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer

class WollokAdvancedProgrammingPreferencePage extends WollokAbstractGlobalPreferencePage {
	override buildConfigurationBlock(IPreferenceStore store, IWorkbenchPreferenceContainer container) {
		new WollokAdvancedProgrammingConfigurationBlock(store, container)
	}


}
