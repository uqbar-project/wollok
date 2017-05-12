package org.uqbar.project.wollok.scoping.root

import java.io.File
import org.apache.commons.collections.map.LRUMap
import org.eclipse.emf.ecore.resource.Resource

class WollokRootLocator {

	private static var INSTANCE = new WollokRootLocator

	var cache = new LRUMap(20)

	def static levelsToRoot(Resource resource) {
		INSTANCE.calculateLevelsToRoot(resource)
	}

	def static String fullPackageName(Resource resource) {
		INSTANCE.doFullPackageName(resource)
	}

	def doFullPackageName(Resource resource) {
		val numberOfLevels = resource.calculateLevelsToRoot

		val segments = resource.URI.trimFileExtension.segments
		segments.drop(segments.size - numberOfLevels).join(".")
	}

	def calculateLevelsToRoot(Resource resource) {
		if(resource.URI.toFileString == null)
			return 1
		
		var file = new File(resource.URI.toFileString).absoluteFile.parentFile
		
		var value = cache.get(file) as Integer
		
		if(value == null){
			value = doLevelsToRoot(file)
			cache.put(file, value)	
		}
		
		value
	}

	def doLevelsToRoot(File orig) {
		var file = orig
		var levels = 1
		
		while (file != null) {

			if (!file.canRead)
				return 1

			if (!file.listFiles[name == "wollok.root"].empty) {
				return levels
			}

			file = file.parentFile;
			levels++
		}
		1
	}
}
