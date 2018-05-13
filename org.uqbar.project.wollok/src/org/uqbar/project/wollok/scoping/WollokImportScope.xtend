package org.uqbar.project.wollok.scoping

import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2

class WollokImportScope implements IScope {
	
	val List<ImportNormalizer> normalizers
	val ISelectable localElements

	@Accessors val IScope parent
	@Accessors val EClass type
	
	new(List<ImportNormalizer> namespaceResolvers, IScope parent, ISelectable importFrom, EClass type) {
		this.normalizers = namespaceResolvers
		this.localElements = importFrom
		this.parent = parent
		this.type = type
	}
	
	
	def List<ImportNormalizer> getNormalizers(){
		normalizers
	}
	
	def ISelectable getImportFrom(){
		localElements
	}

	override getAllElements() {
		synchronized (this) {
			val localElementsFound = if(localElements === null) #[] else localElements.getExportedObjectsByType(type) 
			localElementsFound + parent.allElements.filter[EcoreUtil2.isAssignableFrom(type, it.EClass)]
		}
	}
	
	override getElements(QualifiedName name) {
		synchronized (this) {
			val normalizedNames = (#[name] + normalizers.map[it.resolve(name)].filter[it !== null]).toList
			var IEObjectDescription result = null
			
			if(localElements !== null)
			 	result = localElements.getExportedObjectsByType(type).findFirst[normalizedNames.contains(it.name)]
			
			if(result !== null)
				return #[result]
				
			for(n : normalizedNames){
				var r = parent.getElements(n).findFirst[EcoreUtil2.isAssignableFrom(type, it.EClass)]
				if(r !== null) 
					return #[r]
			}
			
			return #[]
		}
	}
	
	override getElements(EObject object) {
		synchronized (this) {
			val localElementsFound = if(localElements === null) #[] else localElements.getExportedObjectsByObject(object) 
			localElementsFound + parent.getElements(object)
		}
	}
	
	override getSingleElement(QualifiedName name) {
		synchronized (this) {
			val result = getElements(name)
			val iterator = result.iterator()
			if (iterator.hasNext())
				return iterator.next()
			return null
		}
	}
	
	override getSingleElement(EObject object) {
		synchronized (this) {
			val result = getElements(object)
			val iterator = result.iterator()
			if (iterator.hasNext())
				return iterator.next()
			return null		
		}
	}
	
}