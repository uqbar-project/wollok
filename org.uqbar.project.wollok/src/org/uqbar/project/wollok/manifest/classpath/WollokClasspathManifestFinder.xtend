package org.uqbar.project.wollok.manifest.classpath

import java.io.File
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
		x.addAll(handleClassloader(this.class.classLoader, filter))
		x
	}
	
	def dispatch handleClassloader(Object x, Function1 <String,Boolean> filter){
		<String>newArrayList
	}
	
	def dispatch handleClassloader(URLClassLoader cl, Function1 <String,Boolean> filter){
		val r = newArrayList
		r.addAll(cl.getResources("").toList)
		r.addAll(cl.URLs)
		crawl(r.map[new File(it.path.replace("%20"," "))], filter)
	}
	
	def dispatch Iterable<String> crawl(Iterable<File> files,Function1 <String,Boolean> filter){
		files.map[crawl(filter)].flatten
	}

	def dispatch Iterable<String> crawl(File[] files,Function1 <String,Boolean> filter){
		files.map[crawl(filter)].flatten
	}
	
	def dispatch Iterable<String> crawl(File f,Function1 <String,Boolean> filter){
		if(f.directory){
			f.listFiles.crawl(filter)
		}else{
			if(f.name.endsWith("jar"))
				f.crawlJar(filter)
			else
				if(filter.apply(f.name))
					#[f.name]
				else
					#[]
		}
	}
	
	def Iterable<String> crawlJar(File f, Function1 <String,Boolean> filter){
		var JarFile jarFile = null
		try{
			jarFile = new JarFile(f)
			jarFile.entries.toList.map[name].filter(filter)
		}finally{
			if(jarFile != null)
				jarFile.close
		}
	}
	
	def <E> toList(Enumeration<E> enumeration){
		val r = <E>newArrayList
		while(enumeration.hasMoreElements){
			r.add(enumeration.nextElement)
		}
		r
	}
}