package org.uqbar.project.wollok.ui.preferences

import org.eclipse.core.resources.IProject
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.IWorkbenchPreferenceContainer

/**
 * @author jfernandes
 */
class FeaturesPreferencePage extends AbstractWollokPropertyAndPreferencePage {

	override pageID() { "features" }
	
	override createBlock(IProject project, IPreferenceStore preferenceStore, IWorkbenchPreferenceContainer container) {
		new FeaturesConfigurationBlock(project, preferenceStore, container)
	}

}