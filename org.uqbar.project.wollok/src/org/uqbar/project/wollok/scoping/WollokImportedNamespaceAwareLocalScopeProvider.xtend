package org.uqbar.project.wollok.scoping

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

import static java.util.Collections.singletonList

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.scoping.WollokScopeExtensions.*

/**
 * @author tesonep
 * @author jfernandes
 */
class WollokImportedNamespaceAwareLocalScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	
	@Inject
	IQualifiedNameConverter qualifiedNameConverter
	
	override protected getImplicitImports(boolean ignoreCase) {
		val implicits = super.getImplicitImports(ignoreCase)
		val r = newArrayList
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lib"), true, ignoreCase))
		r.add(new ImportNormalizer(qualifiedNameConverter.toQualifiedName("wollok.lang"), true, ignoreCase))
		r.addAll(implicits)
		r
	}
	
	/*
	 * I override this to allow the relative imports, the original version only uses absolute imports.
	 */
	override protected getImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		throw new RuntimeException("It should never reach here")
	}
	
	def getImportedNamespaceResolvers(EObject context, boolean ignoreCase, IScope scope) {
		val result = <ImportNormalizer>newArrayList()
			
		val namespaces = context.allImports.map [ #[importedNamespace] + this.allRelativeImports(importedNamespace, context)].flatten.toSet

		namespaces.filter [ ns | 
			scope.containsImport(ns)
		].forEach [
			val normalizer = createImportedNamespaceResolver(it, ignoreCase)
			if (normalizer !== null) {
				result.add(normalizer)
			}
		]

		result
	}
	
	override protected getLocalElementsScope(IScope parent, EObject context, EReference reference) {
		var result = parent;
		var allDescriptions = getAllDescriptions(context.eResource());
		var name = getQualifiedNameOfLocalElement(context);
		var ignoreCase = isIgnoreCase(reference);
		val List<ImportNormalizer> namespaceResolvers = getImportedNamespaceResolvers(context, ignoreCase, result);
		if (!namespaceResolvers.isEmpty()) {
			if (isRelativeImport() && name!==null && !name.isEmpty()) {
				val localNormalizer = doCreateImportNormalizer(name, true, ignoreCase); 
				result = createImportScope(result, singletonList(localNormalizer), allDescriptions, reference.getEReferenceType(), isIgnoreCase(reference));
			}
			result = createImportScope(result, namespaceResolvers, null, reference.getEReferenceType(), isIgnoreCase(reference));
		}
		if (name!==null) {
			val localNormalizer = doCreateImportNormalizer(name, true, ignoreCase); 
			result = createImportScope(result, singletonList(localNormalizer), allDescriptions, reference.getEReferenceType(), isIgnoreCase(reference));
		}
		return result;
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