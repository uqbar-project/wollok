package org.uqbar.project.wollok.ui.preferences

import org.eclipse.jface.preference.IPreferenceStore

/**
 * Preferences utilities
 * 
 * @author jfernandes
 */
class WPreferencesUtils {
	public static val TRUE = IPreferenceStore.TRUE
	public static val FALSE = IPreferenceStore.FALSE
	
	def static booleanPrefValues() { #[TRUE, FALSE ] }
	
}