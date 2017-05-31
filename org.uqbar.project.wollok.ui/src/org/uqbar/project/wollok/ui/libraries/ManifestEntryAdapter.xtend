package org.uqbar.project.wollok.ui.libraries

import java.io.InputStream
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.emf.common.util.URI
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.uqbar.project.wollok.libraries.StandardWollokLib
import org.uqbar.project.wollok.libraries.WollokLibLoader
import org.uqbar.project.wollok.libraries.WollokManifest
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.eclipse.jdt.core.IPackageFragment
import org.eclipse.jdt.core.IJavaElement

/**
 * If the library is a jar file then the manifest is in a 
 * JarResourceEntry, but if the library is in another java project
 * then the manifest is in a IFile
 */
abstract class ManifestEntryAdapter extends WollokLibLoader{
	
	
	def static boolean isManifestEntry(String name) {
		name != StandardWollokLib.standardLibManifestName
		&& name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)
	}	
	
	// 	the nice way is to create an adapter and to resolve 
	// polymorphicly, but it has a huge instantiation overhead.
	// So, only it creates an object if is necesary
	static def boolean isManifestEntry(Object decorated, IResource project) {
		switch decorated {
			IFile : isManifestEntry(IFileAdapter.toName(decorated)) && project != decorated.project //skip manifest from same project, because is not a library!
			IJarEntryResource : isManifestEntry(IJarEntryResourceAdapter.toName(decorated))
			default : false
		}	
	}
	
	static def create(IPackageFragmentRoot root, Object decorated) {
		switch decorated {
			IFile : new IFileAdapter(decorated)
			IJarEntryResource : new IJarEntryResourceAdapter(root, decorated)
			default : throw new RuntimeException("no adapter type for " + decorated)
		}
	}

	def abstract InputStream inputStream()
	

	def abstract String name()
	
	 
	def WollokManifest manifest()
	
	
	def abstract boolean isForUri(String uri)
	
	
}

class IJarEntryResourceAdapter extends ManifestEntryAdapter {
	
	val IJarEntryResource decorated; 
	val IPackageFragmentRoot fragmentRoot
	
	new(IPackageFragmentRoot fragmentRoot, IJarEntryResource decorated) {
		this.decorated = decorated
		this.fragmentRoot = fragmentRoot
	}
	
	override inputStream() {
		decorated.contents
	}
	
	override name() {
		return toName(decorated)
	}
	
	def static String toName(IJarEntryResource entry) {
		return entry.name	
	}
	
	override isForUri(String uri) {
		return decorated.fullPath.toString.libName == uri.libName
	}
	
	override manifest() {
		return new WollokManifest(inputStream, [ line|
				URI.createURI("platform:/" + fragmentRoot.path + "!/" + line)
		]);
	}
	
	override  def load(URI uri, Resource resource, Manager manager) {	
		val entry = uri.toEntry()
		var newResource = resource.resourceSet.getResource(uri, false)
		if (newResource === null) {
				newResource = resource.resourceSet.createResource(uri)
		} 
		newResource.load(entry.contents, #{})
		manager.getResourceDescription(newResource).exportedObjects
	}
	
	def toEntry(URI uri) {
		val fileName = uri.toString.split("!/").get(1)
		fileName.findEntry()	
	}
		
	def IJarEntryResource findEntry(String fileName) {
		//TODO mejorar esto para no tener que mapear casi todo a null
		fragmentRoot.children.map[it.findFragment(fileName, fragmentRoot)].findFirst[it !== null]
	}
	
	
	def reallyNonJavaResource(IPackageFragment element) {
		return if (element.isDefaultPackage) {fragmentRoot.nonJavaResources} else {element.nonJavaResources}
	}
	
	def IJarEntryResource findFragment(IJavaElement javaElement, String fileName, IPackageFragmentRoot root) {
		if(javaElement instanceof IPackageFragment) {
			val packageFolder = javaElement.elementName.replaceAll("\\.", "/")
			if(fileName.startsWith(packageFolder)) {
				var newFileName = fileName.substring(packageFolder.length())
				newFileName = if(newFileName.startsWith("/")) newFileName.substring(1) else newFileName
				javaElement.reallyNonJavaResource().findFragment(newFileName)
			}
			else {
				null
			}		
		}
		else {
			null
		}
	}
	
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

class IFileAdapter extends ManifestEntryAdapter {
	val IFile decorated
	
	new(IFile decorated) {
		this.decorated = decorated
	}
	
	override inputStream() {
		decorated.contents
	}
	
	override name() {
		return toName(decorated)
	}
	
	def static String toName(IFile file) {
		return file.name	
	}
	override isForUri(String uri) {
		return decorated.parent.toString().endsWith(uri)
	}
	
	override manifest() {
		return new WollokManifest(inputStream);
	}
	
	
}
