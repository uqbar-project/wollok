package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.manifest.WollokManifestFinder

class WollokGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject
	IResourceDescription.Manager resourceDescriptionManager
	@Inject
	WollokManifestFinder manifestFinder

	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type,
		Predicate<IEObjectDescription> filter) {
		val resourceSet = context.resourceSet

		val exportedObjects = manifestFinder.allManifests(resourceSet).map[handleManifest(resourceSet)].flatten

		val defaultScope = super.getScope(parent, context, ignoreCase, type, filter)
		new SimpleScope(defaultScope, exportedObjects)
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
