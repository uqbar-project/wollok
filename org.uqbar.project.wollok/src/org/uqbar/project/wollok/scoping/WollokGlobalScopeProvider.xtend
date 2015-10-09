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

/**
 * 
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
		val explicitImportedObjects = this.importedObjects(context, exportedObjects)

		val defaultScope = super.getScope(parent, context, ignoreCase, type, filter)
		new SimpleScope(new SimpleScope(defaultScope, exportedObjects), explicitImportedObjects)
	}
	
	def importedObjects(Resource resource, Iterable<IEObjectDescription> objectsFromManifests) {
		val rootObject = resource.contents.get(0)
		val imports = rootObject.getAllContentsOfType(Import)
		val importedNamespaces = imports.map[importedNamespace]
		importedNamespaces
		.filter[name|
			// filters those imported from libraries, we won't handle them as regular imports
			// this needs further works if we add more complex imports like *, or aliases.
			!objectsFromManifests.exists[o| o.qualifiedName.toString == name]
		]
		.map[name|
			var uri = generateUri(resource, name)
			val r = EcoreUtil2.getResource(resource, uri)
			if (r == null) throw new WollokRuntimeException("Could NOT find resource '" + name +"'");
			r
		]
		.map[r |
			resourceDescriptionManager.getResourceDescription(r).exportedObjects
		].flatten
	}
	
	def generateUri(Resource resource, String importedName) {
		resource.URI.trimSegments(1).appendSegment(importedName.split("\\.").get(0)).appendFileExtension("wlk").toString
	}

	def handleManifest(WollokManifest manifest, ResourceSet resourceSet) {
		manifest.allURIs.map[loadResource(resourceSet)].flatten
	}

	def loadResource(URI uri, ResourceSet resourceSet) {
		val resource = resourceSet.getResource(uri, true)
		resource.load(#{})

		resourceDescriptionManager.getResourceDescription(resource).exportedObjects
	}
}
