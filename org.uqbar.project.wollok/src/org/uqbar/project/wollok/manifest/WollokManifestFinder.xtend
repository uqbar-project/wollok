package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.ResourceSet

interface WollokManifestFinder {
	def Iterable<WollokManifest> allManifests(ResourceSet resourceSet)
}
