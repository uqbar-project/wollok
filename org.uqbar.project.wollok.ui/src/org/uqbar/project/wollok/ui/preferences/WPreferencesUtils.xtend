package org.uqbar.project.wollok.ui.preferences

import org.eclipse.jface.preference.IPreferenceStore

/**
 * Preferences utilities
 * 
 * @author jfernandes
 */
class WPreferencesUtils {
	public static val TRUE = IPreferenceStore.TRUE
	
	def static booleanPrefValues() { #[TRUE, IPreferenceStore.FALSE ] }
	
}