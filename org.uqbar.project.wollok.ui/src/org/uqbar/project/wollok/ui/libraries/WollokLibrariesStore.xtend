package org.uqbar.project.wollok.ui.libraries

import org.eclipse.core.resources.IProject
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.core.JavaModelException

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
			//the project is not a java project
			//so, no library can be added
			return #[]
		}
	}
	
	def static Iterable<IPackageFragmentRoot> getWollokLibrariesClasspathEntries(IJavaProject project) {
		project.allPackageFragmentRoots.filter[it.isWollokLib(project.project)]
	}

	def static isWollokLib(IPackageFragmentRoot root, IProject project) {
		return hasManifest(root, project)
	}

	def static isWollokLib(IPackageFragmentRoot root, String uri, IProject project) {
		return isWollokLib(root, project) && root.wmanifestEntry(project).isForUri(uri)
	}
	
	def static hasManifest(IPackageFragmentRoot root, IProject project) {
		  root.nonJavaResources.findFirst[ 
		 	ManifestEntryAdapter.isManifestEntry(it, project)
				] !== null 
	}
	
	
	def static wmanifestEntry(IPackageFragmentRoot fragmentRoot, IProject project) {
		
		 val fragment = fragmentRoot.nonJavaResources.findFirst[ 
		 	ManifestEntryAdapter.isManifestEntry(it, project)
				] 
		return ManifestEntryAdapter.create(fragmentRoot, fragment) 
	}
	
	

}