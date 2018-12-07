package org.uqbar.project.wollok.scoping.cache

import com.google.inject.Singleton
import java.util.Set
import org.apache.commons.collections.map.LRUMap
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.xbase.lib.Functions.Function0

@Singleton
class MapBasedWollokGlobalScopeCache implements WollokGlobalScopeCache {
	
	val cache = new LRUMap(20)
	
	override synchronized get(URI uri, Set<String> imports, Function0<Iterable<IEObjectDescription>> ifAbsentBlock) {
		val uriString = uri.toString
		var cacheContent = cache.get(uriString) as MapBasedCacheContent
		if (cacheContent === null || cacheContent.mismatch(imports)) {
			cacheContent = new MapBasedCacheContent(uri, imports, ifAbsentBlock.apply)
			cache.put(uriString, cacheContent)
		}
		cacheContent.result
	}
	
	override synchronized invalidateDependencies(URI uri) {
		val Set<String> uris = cache.keySet
		
		uris.clone.filter [ String uriDependency | 
			(cache.get(uriDependency) as MapBasedCacheContent).hasDependencyWith(uri)
		].forEach [
			cache.remove(it)
		]
		cache.remove(uri.toString)
	}
}

class MapBasedCacheContent {
	val String uri
	val Set<String> imports
	val Iterable<IEObjectDescription> result

	def String uri() { uri }
	def Set<String> imports() { imports }
	def Iterable<IEObjectDescription> result() { result }
		
	new(URI uri, Set<String> imports, Iterable<IEObjectDescription> result){
		this.uri = uri.toString
		this.imports = imports.toSet
		
		// Ensure materialization of results
		this.result = result.toList
	}
	
	def mismatch(Set<String> imports){
		this.imports.hashCode !== imports.hashCode || !this.imports.equals(imports)
	}
	
	def hasDependencyWith(URI uri) {
		this.result.exists [ EObjectURI.toString.toUpperCase.contains(uri.toString.toUpperCase) ]
	}
	
}