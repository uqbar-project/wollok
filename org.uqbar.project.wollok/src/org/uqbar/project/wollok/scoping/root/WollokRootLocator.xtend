package org.uqbar.project.wollok.scoping.root

import org.apache.commons.collections.map.LRUMap
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.URIConverter
import static extension org.uqbar.project.wollok.WollokConstants.*

class WollokRootLocator {

	private static var INSTANCE = new WollokRootLocator

	var cache = new LRUMap(20)

	def static levelsToRoot(Resource resource) {
		INSTANCE.calculateLevelsToRoot(resource)
	}

	def static String fullPackageName(Resource resource) {
		INSTANCE.doFullPackageName(resource)
	}
	
	def static String rootDirectory(Resource resource){
		INSTANCE.doRootDirectory(resource)
	}
	
	def doRootDirectory(Resource resource){
		val uri = resource.URI
		uri.trimSegments(calculateLevelsToRoot(resource)).toFileString
	}

	def doFullPackageName(Resource resource) {
		val numberOfLevels = resource.calculateLevelsToRoot

		val segments = resource.URI.trimFileExtension.segments
		segments.drop(segments.size - numberOfLevels).join(".")
	}

	def calculateLevelsToRoot(Resource resource) {
		val uri = resource.URI
		
		if(uri.toString.contains(CLASSPATH))
			return 1
		
		val parent = uri.trimSegments(1)
		
		var value = cache.get(parent) as Integer
		
		if(value === null){
			value = doLevelsToRoot(parent, resource.resourceSet.URIConverter)
			cache.put(parent, value)	
		}
		
		value
	}

	def doLevelsToRoot(URI orig, URIConverter converter) {
		var file = orig
		var levels = 1
		
		while (file !== null) {

			if (!converter.exists(file, null))
				return 1

			if (converter.exists(file.appendSegment("WOLLOK").appendFileExtension("ROOT"), null)) {
				return levels
			}

			if(file.segmentCount == 1) return 1
			if(file == file.trimSegments(1)) return 1

			file = file.trimSegments(1);
			levels++
		}
	}
}
