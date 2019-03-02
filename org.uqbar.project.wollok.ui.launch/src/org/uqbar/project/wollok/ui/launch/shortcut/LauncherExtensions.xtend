package org.uqbar.project.wollok.ui.launch.shortcut

import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.preferences.WollokDynamicDiagramConfigurationBlock

import static extension org.uqbar.project.wollok.ui.launch.shortcut.WDebugExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import org.uqbar.project.wollok.ui.preferences.WPreferencesUtils

class LauncherExtensions {

	static def activateDynamicDiagramIfNeeded(ILaunchConfiguration config, IPreferenceStoreAccess preferenceStoreAccess) {
		if (config.hasRepl && preferenceStoreAccess.dynamicDiagramActivated) {
			RunInUI.runInUI [
				WollokActivator.DYNAMIC_DIAGRAM_VIEW_ID.openView
			]
		}
	}

	static def boolean dynamicDiagramActivated(IPreferenceStoreAccess preferenceStoreAccess) {
		val store = preferenceStoreAccess.writablePreferenceStore
		var result = store.getString(WollokDynamicDiagramConfigurationBlock.ACTIVATE_DYNAMIC_DIAGRAM_REPL)
		if (result === null || result.equals("")) {
			store.putValue(WollokDynamicDiagramConfigurationBlock.ACTIVATE_DYNAMIC_DIAGRAM_REPL, WPreferencesUtils.TRUE)
			result = WPreferencesUtils.TRUE
		}
		result.equalsIgnoreCase(WPreferencesUtils.TRUE)
	}

}
