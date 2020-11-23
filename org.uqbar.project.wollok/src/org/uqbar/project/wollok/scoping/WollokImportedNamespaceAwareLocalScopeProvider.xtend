package org.uqbar.project.wollok.scoping

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.Iterator
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.ISelectable
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractGlobalScopeDelegatingScopeProvider
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.MultimapBasedSelectable
import org.eclipse.xtext.util.OnChangeEvictingCache

import static java.util.Collections.singletonList
import static org.uqbar.project.wollok.libraries.WollokLibExtensions.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.scoping.WollokScopeExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * @author tesonep
 * @author jfernandes
 * @author npasserini
 * @author fdodino
 */
@Singleton
class WollokImportedNamespaceAwareLocalScopeProvider extends AbstractGlobalScopeDelegatingScopeProvider {

	@Inject
	IQualifiedNameConverter qualifiedNameConverter

	@Inject
	IQualifiedNameProvider qualifiedNameProvider

	// ************************************************************************
	// ** Public interface
	// ************************************************************************
	override getScope(EObject context, EReference reference) {
		synchronized(context.eResource)
			// synchronized(context.eResource.resourceSet)
				context.computeScope(reference)
	}

	def Iterable<String> allRelativeImports(String importedNamespace, EObject context) {
		importedNamespace.allRelativeImports(context.implicitPackage)
	}

	def Iterable<String> allRelativeImports(String importedNamespace, String implicitPackage) {
		val implicitPackageFQN = qualifiedNameConverter.toQualifiedName(implicitPackage)

		(0 .. implicitPackageFQN.segmentCount).map [ i |
			if(importedNamespace !== null) {
				implicitPackageFQN.skipLast(i).append(importedNamespace).toString
			}
		]
	}

	// ************************************************************************
	// ** Internal implementation
	// ************************************************************************
	protected def IScope computeScope(EObject context, EReference reference) {
		val IScope parent = if (context.eContainer !== null)
				context.eContainer.computeScope(reference)
			else 
				context.eResource.resourceScope(reference)

		context.localElementsScope(parent, reference)
	}

	protected def resourceScope(Resource context, EReference reference) {
		val globalScope = context.getGlobalScope(reference)
		val normalizers = context.getImportedNamespaceResolvers(reference)

		createImportScope(globalScope, normalizers, context.allDescriptions, reference.EReferenceType)
	}

	protected def localElementsScope(EObject context, IScope parent, EReference reference) {
		val name = qualifiedNameProvider.getFullyQualifiedName(context)
		if (name !== null) {
			val localNormalizer = new ImportNormalizer(name, true, reference.isIgnoreCase)
			createImportScope(parent, singletonList(localNormalizer), null, reference.EReferenceType)
		} else
			parent
	}

	protected def getImplicitImports() {
		IMPLICIT_IMPORTS.map [
			new ImportNormalizer(qualifiedNameConverter.toQualifiedName(it), true, false)
		]
	}

	protected def getImportedNamespaceResolvers(Resource context, EReference reference) {
		val cache = new OnChangeEvictingCache().getOrCreate(context)
		var result = cache.get("ImportedNamespaceResolvers")

		if(result === null) {
			result = doGetImportedNamespaceResolvers(context.contents.get(0), getGlobalScope(context, reference))
			cache.set("ImportedNamespaceResolvers", result)
		}

		result
	}

	protected def doGetImportedNamespaceResolvers(EObject context, IScope globalScope) {
		(implicitImports + context.allImports.flatMap [
			#[importedNamespace] + importedNamespace.allRelativeImports(context)
		].toSet.filter[globalScope.containsImport(it)].map[createImportedNamespaceResolver].filter[it !== null]
		).toList
	}

	/**
	 * Create a new {@link ImportNormalizer} for the given namespace.
	 * 
	 * @param namespace the namespace.
	 * @param ignoreCase <code>true</code> if the resolver should be case insensitive.
	 * @return a new {@link ImportNormalizer} or <code>null</code> if the namespace cannot be converted to a valid
	 * qualified name.
	 */
	protected def ImportNormalizer createImportedNamespaceResolver(String namespace) {
		if(namespace.isEmpty) return null

		val importedNamespace = qualifiedNameConverter.toQualifiedName(namespace)
		if(importedNamespace.nullOr[isEmpty]) return null

		if(importedNamespace.hasWildCard)
			if(importedNamespace.segmentCount <= 1)
				null
			else
				new ImportNormalizer(importedNamespace.skipLast(1), true, false)
		else
			new ImportNormalizer(importedNamespace, false, false)
	}

	protected def getAllDescriptions(Resource resource) {
		val Iterable<EObject> allContents = new Iterable<EObject>() {
			override Iterator<EObject> iterator() {
				EcoreUtil.getAllContents(resource, false).filter [ eContainer === null || eContainer.hasGlobalDefinitions ]
			}
		}
		val allDescriptions = Scopes.scopedElementsFor(allContents, qualifiedNameProvider)
		new MultimapBasedSelectable(allDescriptions)
	}

	protected def createImportScope(IScope parent, List<ImportNormalizer> namespaceResolvers, ISelectable importFrom,
		EClass type) {

		if(parent instanceof WollokImportScope) {
			val parentImport = parent as WollokImportScope

			if(parentImport.normalizers == namespaceResolvers && importFrom === null && parentImport.type == type)
				return parentImport
		}

		new WollokImportScope(namespaceResolvers, parent, importFrom, type)
	}

	// ************************************************************************
	// ** Helpers
	// ************************************************************************
	def hasWildCard(QualifiedName it) { lastSegment.equals("*") }
}
