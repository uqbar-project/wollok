package org.uqbar.project.wollok.ui.libraries

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.internal.core.JarEntryResource
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.libraries.AbstractWollokLib
import org.uqbar.project.wollok.libraries.WollokManifest


/**
 * It Searchs the wollok manifest and all resources referenced by that file using a jdt JavaProject.
 * @author lgassman
 */
class ClasspathEntryWollokLib extends AbstractWollokLib {
	
	var String uri
	var IJavaProject project
	
	new(IJavaProject project, String uri, Manager manager) {
		super(manager)
		this.uri = uri
		this.project = project
	}
	
	def libName() {
		return uri.libName()
	}


	override getManifest(Resource resource) {
		getPackageFragmentRoot().createManifest(resource)
	}
	
	protected def IPackageFragmentRoot getPackageFragmentRoot() {
		project.allPackageFragmentRoots.findFirst[isThisWollokLib()]
	}
	
	def createManifest(IPackageFragmentRoot fragmentRoot, Resource resource) {
	
		new WollokManifest(fragmentRoot.wmanifestEntry().contents, [ line| 
				URI.createURI(fragmentRoot.path + "!" + line.findEntry(fragmentRoot).fullPath)
		])
		
	} 
	
	def isThisWollokLib(IPackageFragmentRoot fragmentRoot) {
		return fragmentRoot.getElementName().libName ==  this.libName
	}
	
	def wmanifestEntry(IPackageFragmentRoot fragmentRoot) {
		fragmentRoot.nonJavaResources.findFirst[ 
				(it instanceof JarEntryResource) && 
				(it as JarEntryResource).name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)
				] as JarEntryResource
	}
	
	override internalLoad(URI uri, Resource resource) {
		val entry = uri.toEntry()
		var newResource = resource.resourceSet.getResource(uri, false)
		if (newResource === null) {
				newResource = resource.resourceSet.createResource(uri)
		} 
		newResource.load(entry.contents, #{})
		return manager.getResourceDescription(newResource).exportedObjects
	}
	
	def toEntry(URI uri) {
		val fileName = uri.toString.split("!/").get(1)
		fileName.findEntry(getPackageFragmentRoot)	
	}
		
	def IJarEntryResource findEntry(String fileName, IPackageFragmentRoot fragment) {
		
		return fragment.nonJavaResources.findFragment(fileName)
	}
	
	//the javadoc says that all entries are instance of IJarResourceEntry
	def IJarEntryResource findFragment(Object[] entries, String fileName) {
		val filePart = fileName.split("/");
		
		var searching = entries
		var Object r
		for(String part : filePart) {
			r = entries.findFirst[
				(it as IJarEntryResource).name == part
			]	
			//i think that this if is not necesary
			if(r === null) {return null}	
			searching = (r as IJarEntryResource).children
		}
		return r as IJarEntryResource 
	}
		
		
}