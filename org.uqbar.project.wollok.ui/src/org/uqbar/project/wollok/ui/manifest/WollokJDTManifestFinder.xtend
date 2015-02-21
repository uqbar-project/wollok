package org.uqbar.project.wollok.ui.manifest

import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jdt.core.IJarEntryResource
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.IPackageFragmentRoot
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.manifest.WollokManifestFinder

class WollokJDTManifestFinder implements WollokManifestFinder{

	override allManifests(ResourceSet resourceSet) {
		val javaProject = this.getJavaProject(resourceSet)

		if (javaProject != null) {
			javaProject.allPackageFragmentRoots.map[visitClasspathElements].flatten
		} else
			newArrayList
	}

	def IJavaProject getJavaProject(ResourceSet resourceSet) {
		if (resourceSet instanceof XtextResourceSet) {
			val xtextResourceSet = resourceSet as XtextResourceSet
			val context = xtextResourceSet.getClasspathURIContext();
			context as IJavaProject
		} else
			null;
	}

	def visitClasspathElements(IPackageFragmentRoot x) {
		x.nonJavaResources.map[visitNonJavaResource].flatten
	}

	def dispatch visitNonJavaResource(Object x) {
		newArrayList
	}

	def dispatch visitNonJavaResource(IJarEntryResource x) {
		if (x.name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)) {
			newArrayList(new WollokManifest(x.contents))
		} else
			newArrayList
	}

	def dispatch visitNonJavaResource(IFile x) {
		if (x.name.endsWith(WollokManifest.WOLLOK_MANIFEST_EXTENSION)) {
			newArrayList(new WollokManifest(x.contents))
		} else
			newArrayList
	}
}
