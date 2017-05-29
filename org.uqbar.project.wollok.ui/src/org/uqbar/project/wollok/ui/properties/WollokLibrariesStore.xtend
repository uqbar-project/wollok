package org.uqbar.project.wollok.ui.properties

import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.JavaModelException
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.uqbar.project.wollok.libraries.StandardWollokLib
import org.eclipse.jdt.core.IJarEntryResource
import org.uqbar.project.wollok.libraries.WollokManifest

/**
 * Extension methods to manage libraries options for a wollok project
 * 
 * @author lgassman
 */
class WollokLibrariesStore {
	
	def static loadLibs(IProject project) { 
		try {
			var IJavaProject javaProject =	JavaCore.create(project);
			return javaProject.getWollokLibrariesClasspathEntries().map[it.path.toString]
		}
		catch(JavaModelException e) {
			//the project is not a java project,
			System.err.println("Lanzo error el javaModel para el proyecto " + project + ". Error: " + e.message)
			return #[]
		}
	}
	
	def static Iterable<IPackageFragmentRoot> getWollokLibrariesClasspathEntries(IJavaProject project) {
		project.allPackageFragmentRoots.filter[it.isWollokLib]
	}

	def static isWollokLib(IPackageFragmentRoot root) {
		val entry = root.wmanifestEntry 
		//hack: standard lib must be skiped
		entry !== null && entry.name != StandardWollokLib.standardLibManifestName
	}

	def static wmanifestEntry(IPackageFragmentRoot fragmentRoot) {
		fragmentRoot.nonJavaResources.findFirst[ 
				(it instanceof IJarEntryResource) && 
				(it as IJarEntryResource).name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)
				] as IJarEntryResource
	}

	
/* 	def static loadLibs(IPreferenceStore preferenceStore) {
		val libs = preferenceStore.getString(LIBS);
		if (libs !== null && !libs.trim().isEmpty()) Arrays.asList(libs.split(";")) else #[];
	}
*/	


}