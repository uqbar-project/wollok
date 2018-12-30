package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.preferences.WollokDynamicDiagramConfigurationBlock

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

class LauncherExtensions {

	static def activateDynamicDiagramIfNeeded(ILaunchConfiguration config, IPreferenceStoreAccess preferenceStoreAccess) {
		if (config.hasRepl && preferenceStoreAccess.dynamicDiagramActivated) {
			RunInUI.runInUI [
				WollokActivator.DYNAMIC_DIAGRAM_VIEW_ID.openView
			]
		}
	}

	static def boolean dynamicDiagramActivated(IPreferenceStoreAccess preferenceStoreAccess) {
		preferenceStoreAccess.preferenceStore.getBoolean(WollokDynamicDiagramConfigurationBlock.ACTIVATE_DYNAMIC_DIAGRAM_REPL)
	}

}
