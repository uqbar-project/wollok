package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.manifest.WollokLibraryLoader
import org.uqbar.project.wollok.scoping.cache.WollokGlobalScopeCache
import org.uqbar.project.wollok.wollokDsl.Import

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject
	WollokGlobalScopeCache cache

	@Inject
	WollokLibraryLoader libraryLoader
	
	@Inject
	IResourceDescription.Manager resourceDescriptionManager

	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type,
		Predicate<IEObjectDescription> filter) {
		val explicitImportedObjects = context.importedObjects
		val defaultScope = super.getScope(parent, context, ignoreCase, type, filter)
		new SimpleScope(defaultScope, explicitImportedObjects)
	}

	/**
	 * Loads all imported elements from a context
	 */
	def importedObjects(Resource context) {
		val rootObject = context.contents.get(0)
		val imports = rootObject.getAllContentsOfType(Import)
		cache.get(context.URI, imports, [doImportedObjects(context, imports)])
	}

	def doImportedObjects(Resource context, List<Import> imports) {
		val objectsFromManifests = libraryLoader.load(context)

		objectsFromLocalImport(imports, objectsFromManifests, context) + objectsFromManifests
	}
	
	protected def Iterable<IEObjectDescription> objectsFromLocalImport(List<Import> imports, Iterable<IEObjectDescription> objectsFromManifests, Resource context) {
		imports.filter [
			importedNamespace != null && !objectsFromManifests.exists[o|o.matchesImport(importedNamespace)]
		].map [
			toResource(context)
		].filter[it != null].map [ r |
			resourceDescriptionManager.getResourceDescription(r).exportedObjects
		].flatten
	}

	def matchesImport(IEObjectDescription o, String importedNamespace) {
		if (importedNamespace.endsWith(".*")) {
			val pattern = importedNamespace.substring(0, importedNamespace.length - 2)
			o.qualifiedName.toString.startsWith(pattern)
		} else {
			o.qualifiedName.toString == importedNamespace
		}
	}

	/**
	 * Resolves the import to a ECore resource. Here is where the magic of resolving the libraries is performed for the
	 * things that are not in the wollok classpath (found by the WollokManifestFinder).
	 */
	def static toResource(Import imp, Resource resource) {
		try {
			var uri = generateUri(resource, imp.importedNamespace)
			EcoreUtil2.getResource(resource, uri)
		} catch (RuntimeException e) {
			throw new WollokRuntimeException("Error while resolving import '" + imp.importedNamespace + "'", e)
		}
	}

	/**
	 * Converts the importedName to a Resource relative to a context
	 */
	def static generateUri(Resource context, String importedName) {
		context.URI.trimSegments(1).appendSegment(importedName.split("\\.").get(0)).appendFileExtension(
			CLASS_OBJECTS_EXTENSION).toString
	}


}
