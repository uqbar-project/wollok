package org.uqbar.project.wollok.libraries

import java.io.File
import java.io.InputStream
import java.net.URL
import java.net.URLClassLoader
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IResourceDescription.Manager
import static extension org.uqbar.project.wollok.libraries.WollokLibExtensions.libName
/**
 * A Jar Wollok Lib is a library packaged in a jar file.
 * If the jar file is not loaded, it is loaded dynamically.
 * In order to dynamic load to be succesful, a URLClassLoader 
 * must be in the classloader hierarchy.
 * 
 * The wollok manifest file must be called like jar file name
 * for example: if the jar is named pepelib.jar, the manifest name
 * must be called pepelib.wollokmf and must be located in the root
 * of classpath
 * 
 * This class is used by wollok launcher. You must use -lib options
 * in WollokLauncherParamenters to configure the path attribute
 * 
 */
class JarWollokLib extends AbstractWollokLib {
	
	val String path;

	new (String path, Manager manager) {
		super(manager);
		this.path = path;
	}
		
	override doGetManifest(Resource resource) {
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
		if(rs === null) { throw new RuntimeException("manifest is not loaded for lib " + lib + " url: " + lib.libName() + WollokManifest.WOLLOK_MANIFEST_EXTENSION)}
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
		
}