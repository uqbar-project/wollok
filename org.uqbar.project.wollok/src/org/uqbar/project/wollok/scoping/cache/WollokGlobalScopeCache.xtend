package org.uqbar.project.wollok.scoping.cache

import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.xbase.lib.Functions.Function0
import org.uqbar.project.wollok.wollokDsl.Import
import org.eclipse.xtext.resource.IEObjectDescription

interface WollokGlobalScopeCache {
	def Iterable<IEObjectDescription> get(URI uri, List<Import> imports, Function0<Iterable<IEObjectDescription>> ifAbsentBlock)
	def void clearCache()
}