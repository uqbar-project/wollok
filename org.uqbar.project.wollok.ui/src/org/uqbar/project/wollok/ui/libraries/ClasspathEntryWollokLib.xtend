package org.uqbar.project.wollok.ui.libraries

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IJavaElement
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.libraries.AbstractWollokLib

import static extension org.uqbar.project.wollok.ui.libraries.WollokLibrariesStore.*

/**
 * It Searchs the wollok manifest and all resources referenced by that file using a jdt JavaProject.
 * @author lgassman
 */
class ClasspathEntryWollokLib extends AbstractWollokLib {
	
	var String uri
	var IJavaProject project
	var ManifestEntryAdapter entry
	
	new(IJavaProject project, String uri, Manager manager) {
		super(manager)
		this.uri = uri
		this.project = project
		this.entry = getPackageFragmentRoot().wmanifestEntry(project.project)
	}
	
	def wmanifestEntry() {
		return entry
	}
	
	def libName() {
		return uri.libName()
	}

	override getManifest(Resource resource) {
		wmanifestEntry.manifest()
	}
	
	protected def IPackageFragmentRoot getPackageFragmentRoot() {
		project.allPackageFragmentRoots.findFirst[isWollokLib(uri, project.project)]
	}
		
		
	override internalLoad(URI uri, Resource resource) {
		wmanifestEntry.load(uri, resource, manager)
	}
		

}