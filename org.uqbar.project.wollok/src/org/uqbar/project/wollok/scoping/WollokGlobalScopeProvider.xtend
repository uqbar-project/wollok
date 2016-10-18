package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.ClassloaderClasspathUriResolver
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.eclipse.xtext.ui.util.JdtClasspathUriResolver
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.manifest.WollokManifest
import org.uqbar.project.wollok.manifest.WollokManifestFinder
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
	IResourceDescription.Manager resourceDescriptionManager
	@Inject
	WollokManifestFinder manifestFinder

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
	
	def doImportedObjects(Resource context, List<Import> imports){
		val resourceSet = context.resourceSet
		val objectsFromManifests = manifestFinder.allManifests(resourceSet).map[handleManifest(resourceSet)].flatten
		
		imports.filter[
			importedNamespace != null && !objectsFromManifests.exists[o| o.matchesImport(importedNamespace)]
		]
		.map[ 
			toResource(context)
		]
		.filter[it != null]
		.map[r |
			resourceDescriptionManager.getResourceDescription(r).exportedObjects
		].flatten + objectsFromManifests
	}

	def matchesImport(IEObjectDescription o, String importedNamespace){
		if (importedNamespace.endsWith(".*")) {
			val pattern = importedNamespace.substring(0, importedNamespace.length - 2)
			o.qualifiedName.toString.startsWith(pattern)
		}else{
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
		}
		catch (RuntimeException e) {
			throw new WollokRuntimeException("Error while resolving import '" + imp.importedNamespace + "'", e)
		}
	}
	
	/**
	 * Converts the importedName to a Resource relative to a context
	 */
	def static generateUri(Resource context, String importedName) {
		context.URI.trimSegments(1).appendSegment(importedName.split("\\.").get(0)).appendFileExtension(CLASS_OBJECTS_EXTENSION).toString
	}

	/**
	 * Load all resources in the manifests found.
	 */
	def handleManifest(WollokManifest manifest, ResourceSet resourceSet) {
		manifest.allURIs.map[loadResource(resourceSet)].flatten
	}

	/**
	 * This message resolves the loading of a resource, is used by the resources listed in manifests. For the ones not in manifests (in relative locations)
	 * see WollokGlobalScopeProvider#toResource(Import imp, Resource resource)
	 */
	def loadResource(URI uri, ResourceSet resourceSet) {
		try {
			var Iterable<IEObjectDescription> exportedObjects
			//checkResourceSet(resourceSet as XtextResourceSet)
			exportedObjects = WollokResourceCache.getResource(uri)
			if (exportedObjects == null) {
				val resource = resourceSet.getResource(uri, true)
				resource.load(#{})
				exportedObjects = resourceDescriptionManager.getResourceDescription(resource).exportedObjects
				WollokResourceCache.addResource(uri, exportedObjects)
			}
			exportedObjects
		}
		catch (RuntimeException e) {
			throw new RuntimeException("Error while loading resource [" + uri + "]", e)
		} 
	}
	
	/*
	 
	def checkResourceSet(XtextResourceSet resourceSet) {
		if (resourceSet.classpathUriResolver instanceof ClassloaderClasspathUriResolver) {
			resourceSet.classpathUriResolver = new JdtClasspathUriResolver
			resourceSet.classpathURIContext = currentJavaProject
		}
	}
	
	def getCurrentJavaProject() {
		val workspaceRoot = ResourcesPlugin.workspace.root
		val openProjects = workspaceRoot.projects.filter[ project | project.open && project.hasNature(JavaCore.NATURE_ID)]
		var IProject project
		if (openProjects.isEmpty) {
			// TODO, Vemos de donde lo sacamos
			// o generamos uno
		} else {
			project = openProjects.head
		}
		JavaCore.create(project)
	}
	* 
	*/
}
