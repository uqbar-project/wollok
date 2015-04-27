package org.uqbar.project.wollok.manifest.classpath

import java.io.File
import java.net.URL
import java.net.URLClassLoader
import java.util.Enumeration
import java.util.LinkedHashSet
import java.util.jar.JarFile
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.manifest.WollokManifestFinder

class WollokClasspathManifestFinder implements WollokManifestFinder {
	
	override allManifests(ResourceSet resourceSet) {
		val allClassPathEntries = getAllClassPathEntries[endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)]
		
		allClassPathEntries.map[
			new WollokManifest(this.class.classLoader.getResourceAsStream(it))
		]
	}
	
	def getAllClassPathEntries(Function1 <String,Boolean> filter){
		val x = new LinkedHashSet 
		x.addAll(handleClassloader(Thread.currentThread.contextClassLoader, filter))
		x
	}
	
	def dispatch handleClassloader(Object x, Function1 <String,Boolean> filter){
		<String>newArrayList
	}
	
	def dispatch handleClassloader(ClassLoader cl, Function1 <String,Boolean> filter){
		val r = newLinkedHashSet
		r.addAll(cl.getResources("").toList)
		if(cl instanceof URLClassLoader)
			r.addAll(cl.URLs)
		crawl(r.map[new File(normalizePath)], filter)
	}
	
	def dispatch Iterable<String> crawl(Void nothing, Function1 <String,Boolean> filter) {
		#[]
	}
	
	def dispatch Iterable<String> crawl(Iterable<File> files,Function1 <String,Boolean> filter){
		files.map[crawl(filter)].flatten
	}

	def dispatch Iterable<String> crawl(File[] files,Function1 <String,Boolean> filter){
		files.map[crawl(filter)].flatten
	}
	
	def dispatch Iterable<String> crawl(File f,Function1 <String,Boolean> filter){
		if (f.directory) {
			f.listFiles.crawl(filter)
		}
		else {
			if (f.name.endsWith("jar"))
				f.crawlJar(filter)
			else
				if (filter.apply(f.name))
					#[f.name]
				else
					#[]
		}
	}
	
	def Iterable<String> crawlJar(File f, Function1 <String,Boolean> filter){
		var JarFile jarFile = null
		try {
			jarFile = new JarFile(f)
			jarFile.entries.toList.map[name].filter(filter)
		}
		finally {
			jarFile?.close
		}
	}
	
	def normalizePath(URL url){
		var newPath = url.path
		if(newPath.startsWith("file:"))
			newPath = newPath.substring(5)
		newPath.replace("%20"," ")
	}
	
	def <E> toList(Enumeration<E> enumeration) {
		val r = <E>newArrayList
		while(enumeration.hasMoreElements) {
			r.add(enumeration.nextElement)
		}
		r
	}
}