package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.ResourceSet
import org.uqbar.project.wollok.WollokActivator
import com.google.inject.Singleton
import java.util.List
import com.google.inject.Inject
import com.google.inject.name.Named
import java.net.URLClassLoader
import java.io.File
import java.io.InputStream
import java.net.URL

@Singleton
class BasicWollokManifestFinder implements WollokManifestFinder {
	
	@Inject @Named("libraries")
	var List<String> libs = #[]
	
	val manifestNames = #["org.uqbar.project.wollok.lib"->"wollok"]
	
	def newManifest(String bundle, String manifestName){
		val fullName = manifestName + WollokManifest.WOLLOK_MANIFEST_EXTENSION
		
		if (WollokActivator.getDefault != null) {
			new WollokManifest(WollokActivator.getDefault.findResource(bundle, fullName))
		}
		else
			new WollokManifest(class.getResourceAsStream("/" + fullName))
	}
	
	override allManifests(ResourceSet resourceSet) {
		val o = manifestNames.map[newManifest(it.key,it.value)] 
		if (libs.isEmpty()) o else o + libraryManifests()
	}
	
	def libraryManifests() {
		libs.map[libManifest(it)]				
	}
	
	def libManifest(String lib) {
		new WollokManifest(loadAndOpenManifestStream(lib))
	
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
		val rs = class.classLoader.getResourceAsStream( lib.last() + WollokManifest.WOLLOK_MANIFEST_EXTENSION)	
		if(rs === null) { throw new RuntimeException("manifest is not loaded NUEVO")}
		rs
	}

	def last(String st) {
		val s = st.split("/")
		return s.get(s.size - 1)
	}

	def loadLib(String lib) {
		val cl = findUrlClassLoader(class.getClassLoader())
		cl.addURL(new File(lib + ".jar").toURI().toURL())
	}
	
	def addURL(URLClassLoader cl, URL u) {
        val clclass = cl.class;
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
		if(cl instanceof URLClassLoader) cl else findUrlClassLoader(cl.parent)	
	}
	 
}