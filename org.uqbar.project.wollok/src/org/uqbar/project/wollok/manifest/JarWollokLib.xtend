package org.uqbar.project.wollok.manifest

import java.io.File
import java.io.InputStream
import java.net.URL
import java.net.URLClassLoader

class JarWollokLib implements WollokLib {
	
	val String path;

	new (String path){
		this.path = path;
	}
		
	override getManifest() {
		new WollokManifest(loadAndOpenManifestStream(path))
	}
	
	def InputStream loadAndOpenManifestStream(String lib) {
		try {
			return openLibManifestStream(lib)
		}
		catch(RuntimeException e) {
			loadLib(lib)
			return openLibManifestStream(lib)
		}
	}
	
	def openLibManifestStream(String lib) {
		val rs = class.classLoader.getResourceAsStream( lib.name() + WollokManifest.WOLLOK_MANIFEST_EXTENSION)	
		if(rs === null) { throw new RuntimeException("manifest is not loaded")}
		rs
	}
	/** remove path and extension foo/bar.jar => bar */
	def name(String st) {
		val s = st.split("/")
		val r = s.get(s.size - 1)
		r.substring(0,r.length()-4)
	}

	//the implemantation of this is a hack!!
	def loadLib(String lib) {
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
		
}