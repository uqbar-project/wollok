package org.uqbar.project.wollok.manifest

interface WollokManifestFinder {
	def Iterable<WollokManifest> allManifests()
}
