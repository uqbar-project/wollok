package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.manifest.WollokManifestFinder
import org.uqbar.project.wollok.wollokDsl.Import

import static extension org.eclipse.xtext.EcoreUtil2.*

import static org.uqbar.project.wollok.WollokConstants.*
import org.eclipse.xtext.diagnostics.ExceptionDiagnostic
import org.eclipse.xtext.validation.EObjectDiagnosticImpl
import org.eclipse.xtext.diagnostics.Severity
import org.uqbar.project.wollok.wollokDsl.WollokDslPackage

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject
	IResourceDescription.Manager resourceDescriptionManager
	@Inject
	WollokManifestFinder manifestFinder

	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type,
		Predicate<IEObjectDescription> filter) {
		val resourceSet = context.resourceSet

		val exportedObjects = manifestFinder.allManifests(resourceSet).map[handleManifest(resourceSet)].flatten
		val explicitImportedObjects = importedObjects(context, exportedObjects)

		val defaultScope = super.getScope(parent, context, ignoreCase, type, filter)
		new SimpleScope(new SimpleScope(defaultScope, exportedObjects), explicitImportedObjects)
	}
	
	def importedObjects(Resource resource, Iterable<IEObjectDescription> objectsFromManifests) {
		val rootObject = resource.contents.get(0)
		val imports = rootObject.getAllContentsOfType(Import)
		
		imports.filter[
			// filters those imported from libraries, we won't handle them as regular imports
			// this needs further works if we add more complex imports like *, or aliases.
			importedNamespace != null && !objectsFromManifests.exists[o| o.qualifiedName.toString == importedNamespace]
		]
		.map[ 
			toResource(resource)
		]
		.filter[it != null]
		.map[r |
			resourceDescriptionManager.getResourceDescription(r).exportedObjects
		].flatten
	}
	
	def static toResource(Import it, Resource resource) {
		try {
			var uri = generateUri(resource, importedNamespace)
			val r = EcoreUtil2.getResource(resource, uri)
			r
//			if (r != null && EcoreUtil2.isValidUri(resource, r.URI))
//				r
//			else
//				null
		}
		catch (RuntimeException e) {
			throw new WollokRuntimeException("Error while resolving import '" + importedNamespace + "'", e)
		}
	}
	
	def static generateUri(Resource resource, String importedName) {
		resource.URI.trimSegments(1).appendSegment(importedName.split("\\.").get(0)).appendFileExtension(CLASS_OBJECTS_EXTENSION).toString
	}

	def handleManifest(WollokManifest manifest, ResourceSet resourceSet) {
		manifest.allURIs.map[loadResource(resourceSet)].flatten
	}

	def loadResource(URI uri, ResourceSet resourceSet) {
		try {
			val resource = resourceSet.getResource(uri, true)
			resource.load(#{})
			resourceDescriptionManager.getResourceDescription(resource).exportedObjects
		}
		catch (RuntimeException e) {
			throw new RuntimeException("Error while loading resource [" + uri + "]", e)
		} 
	}
}
