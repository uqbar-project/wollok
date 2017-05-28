package org.uqbar.project.wollok.ui.libraries

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader
import java.util.ArrayList
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jdt.internal.core.JarEntryResource
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.manifest.WollokLib
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.scoping.WollokResourceCache

import static extension org.uqbar.project.wollok.manifest.WollokLibrariesExtension.libName

/**
 * Search the wollok manifest file using a jdt JavaProject.
 */
class ClasspathEntryWollokLib implements WollokLib {
	
	var String uri
	var IJavaProject project
	var Manager manager
	
	new(IJavaProject project, String uri, Manager manager) {
		this.uri = uri
		this.project = project
		this.manager = manager
	}
	
	def libName() {
		return uri.libName()
	}
	
	
	override load(Resource resource) {
		project.allPackageFragmentRoots.findFirst[isThisWollokLib()].loadFromManifest(resource)
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
	
	
	def loadFromManifest(IPackageFragmentRoot fragmentRoot, Resource resource) {
	
		fragmentRoot.wmanifestEntry().contents.files.map[load(fragmentRoot, resource)].flatten
	
	} 
	
	def load(String fileName, IPackageFragmentRoot fragmentRoot, Resource resource) {
			val entry = fileName.findEntry(fragmentRoot)
			
			var uri = URI.createURI(fragmentRoot.path + "!" + entry.fullPath)
			
			var Iterable<IEObjectDescription> exportedObjects
			exportedObjects = WollokResourceCache.getResource(uri)
			if (exportedObjects === null) {
				var newResource = resource.resourceSet.getResource(uri, false)
				if (newResource === null) {
					newResource = resource.resourceSet.createResource(uri)
				} 
				newResource.load(entry.contents, #{})
				exportedObjects = manager.getResourceDescription(newResource).exportedObjects
				WollokResourceCache.addResource(uri, exportedObjects)
			}
			
			return exportedObjects
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
		
	def files(InputStream is) {
		try {
			val out = new ArrayList<String>
			val reader = new BufferedReader(new InputStreamReader(is))
			var String file = null
			while((file = reader.readLine) !== null){
				out += file
			}
			return out
		}
		finally {
			try {
				is.close
			}
			catch (Exception e) {
				println("Error while closing input stream on finally")
				e.printStackTrace
			}
		}	
	}
	
 

		
}