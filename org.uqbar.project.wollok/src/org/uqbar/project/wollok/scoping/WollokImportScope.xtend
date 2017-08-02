package org.uqbar.project.wollok.scoping

import java.util.List
import org.apache.commons.collections.map.LRUMap
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportScope
import org.eclipse.xtext.resource.IEObjectDescription
import org.uqbar.project.wollok.utils.ReflectionExtensions

class WollokImportScope extends ImportScope {
	
	val cache = new LRUMap(10)
	
	new(List<ImportNormalizer> namespaceResolvers, IScope parent, ISelectable importFrom, EClass type, boolean ignoreCase) {
		super(namespaceResolvers, parent, importFrom, type, ignoreCase)
	}
	
	override protected getLocalElementsByName(QualifiedName name) {
		var result = cache.get(name) as Iterable<IEObjectDescription>
		
		if(result === null){
			result = super.getLocalElementsByName(name)
			cache.put(name, result)
		}
		
		result
	}
	
	def List<ImportNormalizer> getNormalizers(){
		(ReflectionExtensions.getFieldValue(this,"normalizers")) as List<ImportNormalizer>
	}
	
	def ISelectable getRawImportFrom(){
		(ReflectionExtensions.getFieldValue(this,"importFrom")) as ISelectable
	}

	def getType(){
		(ReflectionExtensions.getFieldValue(this,"type")) as EClass
	}
}