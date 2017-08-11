package org.uqbar.project.wollok.scoping.cache

import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.xbase.lib.Functions.Function0

interface WollokGlobalScopeCache {
	def Iterable<IEObjectDescription> get(URI uri, Set<String> imports, Function0<Iterable<IEObjectDescription>> ifAbsentBlock)
	def void clearCache()
}