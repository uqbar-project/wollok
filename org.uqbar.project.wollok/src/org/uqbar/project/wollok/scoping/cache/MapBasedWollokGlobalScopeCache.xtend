package org.uqbar.project.wollok.scoping.cache

import com.google.inject.Singleton
import java.util.List
import java.util.Set
import org.apache.commons.collections.map.LRUMap
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.xbase.lib.Functions.Function0
import org.uqbar.project.wollok.wollokDsl.Import

@Singleton
class MapBasedWollokGlobalScopeCache implements WollokGlobalScopeCache {
	
	val cache = new LRUMap(20)
	
	override get(URI uri, List<Import> imports, Function0<Iterable<IEObjectDescription>> ifAbsentBlock) {
		val uriString = uri.toString
		var cacheContent = cache.get(uriString) as MapBasedCacheContent
		
		if(cacheContent == null || cacheContent.mismatch(imports)){
			cacheContent = new MapBasedCacheContent(uri, imports, ifAbsentBlock.apply)
			cache.put(uriString, cacheContent)
		}
		
		cacheContent.result
	}
	
	override clearCache() {
		cache.clear
	}
	
}

@Accessors
class MapBasedCacheContent {
	val String uri
	val Set<String> imports
	val Iterable<IEObjectDescription> result
	
	new(URI uri, List<Import> imports, Iterable<IEObjectDescription> result){
		this.uri = uri.toString
		this.imports = imports.map[importedNamespace].toSet
		this.result = newHashSet(result)
	}
	
	def mismatch(List<Import> imports){
		this.imports != imports.map[importedNamespace].toSet
	}
}