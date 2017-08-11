package org.uqbar.project.wollok.scoping

import com.google.inject.Inject
import java.util.Iterator
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractGlobalScopeDelegatingScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.MultimapBasedSelectable
import org.eclipse.xtext.util.OnChangeEvictingCache
import org.eclipse.xtext.util.Strings

import static java.util.Collections.singletonList

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.scoping.WollokScopeExtensions.*

/**
 * @author tesonep
 * @author jfernandes
 */
class WollokImportedNamespaceAwareLocalScopeProvider extends AbstractGlobalScopeDelegatingScopeProvider {
	
	@Inject
	IQualifiedNameConverter qualifiedNameConverter
	
	@Inject
	IQualifiedNameProvider qualifiedNameProvider;

	
	override getScope(EObject context, EReference reference) {
		var IScope result;
		
		if (context.eContainer() !== null) {
			result = getScope(context.eContainer(), reference);
		} else {
			result = getResourceScope(context.eResource(), reference);
		}
		return getLocalElementsScope(result, context, reference);
	}
	
	def protected getResourceScope(Resource context, EReference reference){
		val globalScope = getGlobalScope(context, reference)
		val normalizers = getImportedNamespaceResolvers(context, reference)
		
		createImportScope(globalScope, normalizers, getAllDescriptions(context), reference.EReferenceType)
	}	
		
	
	def protected getImplicitImports() {
		val r = newArrayList
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lib"), true, false))
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lang"), true, false))
		r
	}
	
	def getImportedNamespaceResolvers(Resource context, EReference reference) {
		val cache = new OnChangeEvictingCache().getOrCreate(context);
		var result = cache.get("ImportedNamespaceResolvers")
		
		if(result === null){
			result = doGetImportedNamespaceResolvers(context.contents.get(0), getGlobalScope(context, reference))
			cache.set("ImportedNamespaceResolvers", result)
		}
		
		result
	}
	
	def doGetImportedNamespaceResolvers(EObject context, IScope globalScope) {
		val result = getImplicitImports()
					
		val namespaces = context.allImports.map [ #[importedNamespace] + this.allRelativeImports(importedNamespace, context)].flatten.toSet

		namespaces.filter [ ns | 
			globalScope.containsImport(ns)
		].forEach [
			val normalizer = createImportedNamespaceResolver(it)
			if (normalizer !== null) {
				result.add(normalizer)
			}
		]

		result
	}

	/**
	 * Create a new {@link ImportNormalizer} for the given namespace.
	 * @param namespace the namespace.
	 * @param ignoreCase <code>true</code> if the resolver should be case insensitive.
	 * @return a new {@link ImportNormalizer} or <code>null</code> if the namespace cannot be converted to a valid
	 * qualified name.
	 */
	protected def ImportNormalizer createImportedNamespaceResolver(String namespace) {
		if (Strings.isEmpty(namespace))
			return null;
		val importedNamespace = qualifiedNameConverter.toQualifiedName(namespace);
		if (importedNamespace === null || importedNamespace.isEmpty()) {
			return null;
		}
		val hasWildCard = importedNamespace.getLastSegment().equals("*")

		if (hasWildCard) {
			if (importedNamespace.getSegmentCount() <= 1)
				return null;
			return new ImportNormalizer(importedNamespace.skipLast(1), true, false);
		} else {
			return new ImportNormalizer(importedNamespace, false, false);
		}
	}

	
	def protected getLocalElementsScope(IScope parent, EObject context, EReference reference) {
		var result = parent;
		var name = qualifiedNameProvider.getFullyQualifiedName(context);
		var ignoreCase = isIgnoreCase(reference);

		if (name!==null) {
			val localNormalizer = new ImportNormalizer(name, true, ignoreCase); 
			result = createImportScope(result, singletonList(localNormalizer), null, reference.EReferenceType);
		}
		return result;
	}
	
	protected def getAllDescriptions(Resource resource) {
		val Iterable<EObject> allContents = new Iterable<EObject>(){
			override Iterator<EObject> iterator() {
				EcoreUtil.getAllContents(resource, false);
			}
		}; 
		val allDescriptions = Scopes.scopedElementsFor(allContents, qualifiedNameProvider);
		return new MultimapBasedSelectable(allDescriptions);
	}


	def protected createImportScope(IScope parent, List<ImportNormalizer> namespaceResolvers, ISelectable importFrom, EClass type) {
		if(parent instanceof WollokImportScope){
			val parentImport = parent as WollokImportScope

			if(parentImport.normalizers == namespaceResolvers && importFrom === null && parentImport.type == type)
				return parentImport
		}
		
		new WollokImportScope(namespaceResolvers, parent, importFrom, type)
	}

	def Iterable<String> allRelativeImports(String importedNamespace, EObject context){
		this.allRelativeImports(importedNamespace, context.implicitPackage)
	}

	def Iterable<String> allRelativeImports(String importedNamespace, String implicitPackage){
		val implicitPackageFQN = qualifiedNameConverter.toQualifiedName(implicitPackage)

		(0..implicitPackageFQN.segmentCount).map[ i |
			implicitPackageFQN.skipLast(i).append(importedNamespace).toString
		]
	}
}