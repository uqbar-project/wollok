package org.uqbar.project.wollok.manifest

import java.io.File
import java.io.InputStream
import java.net.URL
import java.net.URLClassLoader
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager
import static extension org.uqbar.project.wollok.manifest.WollokLibrariesExtension.libName

class JarWollokLib implements WollokLib {
	
	val String path;
	val Manager manager;

	new (String path, Manager manager){
		this.path = path;
		this.manager = manager;
	}
		
	def getManifest() {
		new WollokManifest(loadAndOpenManifestStream(path))
	}
	
	def InputStream loadAndOpenManifestStream(String lib) {
		try {
			return openLibManifestStream(lib)
		}
		catch(RuntimeException e) {
			loadJar(lib)
			return openLibManifestStream(lib)
		}
	}
	
	def openLibManifestStream(String lib) {
		val rs = class.classLoader.findUrlClassLoader().getResourceAsStream( lib.libName() + WollokManifest.WOLLOK_MANIFEST_EXTENSION)	
		if(rs === null) { throw new RuntimeException("manifest is not loaded")}
		rs
	}

	//the implementation of this is a hack, but it is a popular hack
	def loadJar(String lib) {
		class.getClassLoader.findUrlClassLoader.addURL(new File(lib).toURI().toURL())
	}
	
	def addURL(URLClassLoader cl, URL u) {
        try {
            val method = URLClassLoader.getDeclaredMethod("addURL", URL);
            method.setAccessible(true);
            method.invoke(cl, u ); 
        } catch (Exception t) {
        	t.printStackTrace()
            throw new RuntimeException("Error, could not add URL to " + cl);
        }        
    }
	
	
	def URLClassLoader findUrlClassLoader(ClassLoader cl) {
		if(cl === null) {throw new RuntimeException("URLClassLoader is not present")}	
		if(cl instanceof URLClassLoader) cl else cl.parent.findUrlClassLoader	
		
	}
	
	override load(Resource resource) {
		manifest.load(resource.resourceSet, manager)
	}
		
}