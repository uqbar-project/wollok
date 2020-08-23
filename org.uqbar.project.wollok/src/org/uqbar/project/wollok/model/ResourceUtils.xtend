package org.uqbar.project.wollok.model

import java.util.Map
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IWorkspace
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.common.util.URI

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.scoping.root.WollokRootLocator.*

/**
 * Extension methods to Wollok semantic model related to files, resources and the Eclipse platform.
 */
class ResourceUtils {

	public static String IMPORT_TEST_PREFFIX = "t_"
	
	public static Map<String, String> implicitPackagePreffixes = #{
		WOLLOK_DEFINITION_EXTENSION -> "",
		TEST_EXTENSION -> IMPORT_TEST_PREFFIX,
		PROGRAM_EXTENSION -> "p_"
	}

	def static getProject(EObject obj) { obj.IFile.project }

	def static IFile getIFile(EObject obj) { obj.eResource.IFile }

	def static IFile getIFile(Resource resource) {
		val resourceURI = resource.URI.toString
		val platformString = if (resourceURI.startsWith(CLASSPATH)) resourceURI else resource.URI.toPlatformString(true) 
		if(platformString === null) {
			// could be a synthetic file
			return null
		}
		workspace.root.getFile(new Path(platformString))
	}

	def static IFile getPlatformFile(EObject o) {
		val platformString = o.eResource.URI.toPlatformString(true)
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
		if(it === null || URI === null || URI.toString === null) {
			return null
		}
		if(URI.toString.startsWith(CLASSPATH))
			URI.trimFileExtension.segments.join(".")
		else
			fullPackageName(it)
	}
	
	def static implicitPackageForImport(Resource it) {
		preffixPackage + implicitPackage
	}
	
	def static preffixPackage(Resource it) {
		URI.preffixForImport
	}

	def static preffixForImport(URI uri) {
		implicitPackagePreffixes.get(uri.fileExtension) ?: ""
	}

}
