package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.Resource

interface WollokManifestFinder {
	def Iterable<WollokManifest> allManifests(Resource resourceSet)
}
