package org.uqbar.project.wollok.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.ClasspathUriResolutionException
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.DefaultGlobalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.libraries.WollokLibraryLoader
import org.uqbar.project.wollok.scoping.cache.WollokGlobalScopeCache
import org.uqbar.project.wollok.scoping.root.WollokRootLocator
import org.uqbar.project.wollok.wollokDsl.Import

import static org.uqbar.project.wollok.WollokConstants.*

import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokGlobalScopeProvider extends DefaultGlobalScopeProvider {

	@Inject
	WollokGlobalScopeCache cache

	@Inject
	WollokLibraryLoader libraryLoader
	
	@Inject
	IResourceDescription.Manager resourceDescriptionManager

	@Inject 
	WollokImportedNamespaceAwareLocalScopeProvider localScopeProvider

	override IScope getScope(IScope parent, Resource context, boolean ignoreCase, EClass type,
		Predicate<IEObjectDescription> filter) {
		var explicitImportedObjects = context.importedObjects
		
		if(filter !== null)
			explicitImportedObjects = explicitImportedObjects.filter(filter)
		
		val defaultScope = super.getScope(parent, context, ignoreCase, type, filter)
		new SimpleScope(defaultScope, explicitImportedObjects)
	}

	/**
	 * Loads all imported elements from a context
	 */
	def importedObjects(Resource context) {
		val rootObject = context.contents.get(0)
		val imports = rootObject.allImports.map[importedNamespace] + rootObject.allFQNImports
		cache.get(context.URI, imports, [doImportedObjects(context, imports)])
		// doImportedObjects(context,imports)
	}

	def doImportedObjects(Resource context, Iterable<String> imports) {
		val objectsFromManifests = libraryLoader.load(context)

		objectsFromLocalImport(context, imports, objectsFromManifests)
	}
	
	def objectsFromLocalImport(Resource context, Iterable<String> importsEntry, Iterable<IEObjectDescription> objectsFromManifests){
		val imports = (importsEntry.map[ #[it]  + localScopeProvider.allRelativeImports(it, context.implicitPackage) ].flatten).toSet
		
		val importedObjects = imports.filter[
			it !== null && !objectsFromManifests.exists[o| o.matchesImport(it)]
		]
		.map[ 
			toResource(context)
		].filter[it !== null].map [ r |
			resourceDescriptionManager.getResourceDescription(r).exportedObjects
		].flatten + objectsFromManifests
		importedObjects
	}

	def matchesImport(IEObjectDescription o, String importedNamespace) {
		if (importedNamespace.endsWith(".*")) {
			val pattern = importedNamespace.substring(0, importedNamespace.length - 2)
			o.qualifiedName.toString.startsWith(pattern)
		} else {
			o.qualifiedName.toString == importedNamespace
		}
	}

	/**
	 * Resolves the import to a ECore resource. Here is where the magic of resolving the libraries is performed for the
	 * things that are not in the wollok classpath (found by the WollokManifestFinder).
	 */	
	def static toResource(String importedNamespace, Resource resource) {
		try {
			var uri = generateUri(resource, importedNamespace)
			if(uri === null) return null
			
			EcoreUtil2.getResource(resource, uri)
		}
		catch (RuntimeException e) {
			throw new WollokRuntimeException("Error while resolving import '" + importedNamespace + "'", e)
		}
	}

	/**
	 * Converts the importedName to a Resource relative to a context
	 */
	def static generateUri(Resource context, String importedName) {
		val levels = WollokRootLocator.levelsToRoot(context)
		val parts = importedName.split("\\.")
		var uri = context.URI.trimSegments(levels)
		
		//I skip the last part because is the name of the imported object
		for(var i = 0; i < parts.size -1 ; i++){
			uri = uri.appendSegment(parts.get(i))
		}
				
		var newUri = uri

		while (newUri.segmentCount >= 1) {
			val fileURI = newUri.appendFileExtension(CLASS_OBJECTS_EXTENSION)
			
			if (fileURI.exists(context)) {
				return fileURI.toString
			}
			
			newUri = newUri.trimSegments(1)
		}

		uri.appendFileExtension(CLASS_OBJECTS_EXTENSION).toString
	}
	
	def static Boolean exists(URI fileURI, Resource context){
		try{
			context.resourceSet.URIConverter.exists(fileURI,null)
		}catch(ClasspathUriResolutionException e){
			false
		}
	}
}
