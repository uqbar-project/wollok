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
import org.uqbar.project.wollok.libraries.WollokManifest

import static extension org.uqbar.project.wollok.ui.properties.WollokLibrariesStore.*

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
		
	def IJarEntryResource findEntry(String fileName, IPackageFragmentRoot root) {
		
		//todo mejorar esto para no tener que mapear casi todo a null
		root.children.map[it.findFragment(fileName, root)].findFirst[it !== null]
			
	}
	
	
	def reallyNonJavaResource(IPackageFragment element, IPackageFragmentRoot root) {
		return if (element.isDefaultPackage) {root.nonJavaResources} else {element.nonJavaResources}
	}
	
	def IJarEntryResource findFragment(IJavaElement javaElement, String fileName, IPackageFragmentRoot root) {
		if(javaElement instanceof IPackageFragment) {
			val packageFolder = javaElement.elementName.replaceAll("\\.", "/")
			if(fileName.startsWith(packageFolder)) {
				var newFileName = fileName.substring(packageFolder.length())
				newFileName = if(newFileName.startsWith("/")) newFileName.substring(1) else newFileName
				javaElement.reallyNonJavaResource(root).findFragment(newFileName)
			}
			else {
				null
			}		
		}
		else {
			null
		}
	}
	
	//the javadoc says that all entries are instance of IJarResourceEntry if is not a java resource
	//but, if the folder is not a java package, can be a JarPackageFragment.
	//apparently, no common superclass exist
	def IJarEntryResource findFragment(Object[] entries, String fileName) {
		val filePart = fileName.split("/");
		
		var searching = entries
		var Object r
		for(String part : filePart) {
			r = searching.findFirst[
				(it instanceof IJarEntryResource) && (it as IJarEntryResource).name == part
			]	
			//the file is not present in this entry
			if(r === null) {return null}	
			searching = (r as IJarEntryResource).children
		}
		return r as IJarEntryResource 
	}
		
		
}