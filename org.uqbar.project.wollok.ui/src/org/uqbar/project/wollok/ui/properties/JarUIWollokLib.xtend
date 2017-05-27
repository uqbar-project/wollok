package org.uqbar.project.wollok.ui.properties

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
import org.eclipse.jdt.internal.core.JarEntryFile
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.manifest.WollokLib
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.scoping.WollokResourceCache

class JarUIWollokLib implements WollokLib {
	
	var String uri
	var IProject project
	
	new(IProject project, String uri) {
		this.uri = uri
		this.project = project
	}
	
	
	override load(Resource resource, Manager manager) {
		val IJavaProject p = JavaCore.create(project)
		p.allPackageFragmentRoots.filter[isWollokLib()].map[loadFromManifest(resource, manager)].flatten
	}
	
	def isWollokLib(IPackageFragmentRoot fragmentRoot) {
		fragmentRoot.wmanifestEntry() !== null
	}
	def wmanifestEntry(IPackageFragmentRoot fragmentRoot) {
		fragmentRoot.nonJavaResources.findFirst[ (it instanceof JarEntryFile) && (it as JarEntryFile).name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)] as JarEntryFile
	}
	
	
	def loadFromManifest(IPackageFragmentRoot fragmentRoot, Resource resource, Manager manager) {
	
		fragmentRoot.wmanifestEntry().contents.files.map[load(fragmentRoot, resource, manager)].flatten
	
	} 
	
	def load(String fileName, IPackageFragmentRoot fragmentRoot, Resource resource, Manager manager) {
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
			if(r === null) {return null}	
			searching = (r as IJarEntryResource).children
		}
		return r as IJarEntryResource 
	}
	
/* 	
	def toPackageName(String[] fileParts) {
		var o = new StringBuilder
		for(var i = 0; i < fileParts.size - 1; i++) {
			o.append(fileParts.get(i))
			if(i == fileParts.size - 2) {
				o.append(".")
			} 
		}
		System.err.println("packageName: " + o)
		return o.toString
	}
*/	
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
	

	/** remove path and extension foo/bar.jar => bar  - Duplicated from JarWollokLib*/
	def name(String st) {
		val s = st.split("/")
		val r = s.get(s.size - 1)
		r.substring(0,r.length()-4)
	}
	
		
}