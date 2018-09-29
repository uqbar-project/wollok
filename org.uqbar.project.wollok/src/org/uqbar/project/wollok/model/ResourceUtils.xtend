package org.uqbar.project.wollok.model

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource

import static org.uqbar.project.wollok.scoping.root.WollokRootLocator.*
import static org.uqbar.project.wollok.WollokConstants.*

/**
 * Extension methods to Wollok semantic model related to files, resources and the Eclipse platform.
 */
class ResourceUtils {

	def static getProject(EObject obj) { obj.IFile.project }

	def static IFile getIFile(EObject obj) { obj.eResource.IFile }

	def static IFile getIFile(Resource resource) {
		// *******************************************************
		// val resourceURI = resource.URI.toString
		// val platformString = if (resourceURI.startsWith(CLASSPATH)) resourceURI else resource.URI.toPlatformString(true)
		// prueba travis
		val platformString = resource.URI.toPlatformString(true)
		// *******************************************************
		if(platformString === null) {
			// could be a synthetic file
			return null
		}
		workspace.root.getFile(new Path(platformString))
	}

	def static IWorkspace workspace() {
		ResourcesPlugin.workspace
	}

	def static dispatch String getPlatformFullPath(Resource resource) {
		resource.IFile.platformFullPath
	}

	def static dispatch String getPlatformFullPath(IResource resource) {
		resource.fullPath.toString
	}

	def static implicitPackage(Resource it) {
		if(it === null || it.URI === null || it.URI.toString === null) {
			return null
		}
		if(URI.toString.startsWith(CLASSPATH))
			URI.trimFileExtension.segments.join(".")
		else
			fullPackageName(it)
	}
}
