package org.uqbar.project.wollok.ui.libraries

import java.io.InputStream
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.emf.common.util.URI
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.uqbar.project.wollok.libraries.StandardWollokLib
import org.uqbar.project.wollok.libraries.WollokManifest

import static extension org.uqbar.project.wollok.libraries.AbstractWollokLib.libName

/**
 * If the library is a jar file then the manifest is in a 
 * JarResourceEntry, but if the library is in another java project
 * then the manifest is in a IFile
 */
abstract class ManifestEntryAdapter {
	
	
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
	
	static def create(Object decorated) {
		switch decorated {
			IFile : new IFileAdapter(decorated)
			IJarEntryResource : new IJarEntryResourceAdapter(decorated)
			default : throw new RuntimeException("no adapter type for " + decorated)
		}
	}

	def abstract InputStream inputStream()
	

	def abstract String name()
	
	 
	def WollokManifest manifest(IPackageFragmentRoot root)
	
	
	def abstract boolean isForUri(String uri)
	
}

class IJarEntryResourceAdapter extends ManifestEntryAdapter {
	
	val IJarEntryResource decorated;
	
	new(IJarEntryResource decorated) {
		this.decorated = decorated
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
	
	override manifest(IPackageFragmentRoot fragmentRoot) {
		return new WollokManifest(inputStream, [ line|
				URI.createURI("platform:/" + fragmentRoot.path + "!/" + line)
		]);
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
	
	override manifest(IPackageFragmentRoot fragmentRoot) {
		return new WollokManifest(inputStream);
	}
	
}
