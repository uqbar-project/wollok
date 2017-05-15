package org.uqbar.project.wollok.ui.properties

import java.util.Arrays
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ProjectScope
import org.eclipse.jface.preference.IPreferenceStore
import org.eclipse.ui.preferences.ScopedPreferenceStore
import org.uqbar.project.wollok.ui.WollokActivator

/**
 * Extension methods to manage libraries options for a wollok project
 * 
 * @author lgassman
 */
class WollokLibrariesStore {
	
	public static val LIBS = "libraries"
	
	def static saveLibs(IProject project, List<String> libraries) {
		project.projectPreference.saveLibs(libraries);
	}
	
	def static ScopedPreferenceStore getProjectPreference(IProject project) {
		new ScopedPreferenceStore(new ProjectScope(project), WollokActivator.BUNDLE_NAME)
	}
		
	def static saveLibs(IPreferenceStore preferenceStore, List<String> libraries ) {
		preferenceStore.setValue(LIBS, String.join(";",libraries));
	}
	
	def static loadLibs(IProject project) { 
		project.projectPreference.loadLibs
	}
	
	def static loadLibs(IPreferenceStore preferenceStore) {
		val libs = preferenceStore.getString(LIBS);
		if (libs !== null && !libs.trim().isEmpty()) Arrays.asList(libs.split(";")) else #[];
	}
	
}