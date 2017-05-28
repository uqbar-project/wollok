package org.uqbar.project.wollok.ui.libraries

import com.google.inject.Inject
import javax.inject.Singleton
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.resource.IResourceDescription.Manager
import org.uqbar.project.wollok.libraries.WollokLib
import org.uqbar.project.wollok.libraries.WollokLibraries

import static extension org.uqbar.project.wollok.ui.properties.WollokLibrariesStore.*

/**
 * It is a WollokLibraries used by the wollok IDE
 * It Uses ClasspathEntryWollokLib instead JarWollokLib
 * because URLContextClass Loader is not presents.
 * It uses a jdt JavaModel to load the libraries
 * 
 * @author leo
 * 
 */
@Singleton
class WollokUILibraries implements WollokLibraries  {

	@Inject
	var Manager manager
	
	@Inject
	var IWorkspaceRoot workspaceRoot


	def getPaths(Resource resource) {
		val project = getProject(resource) 
		if(project !== null) project.loadLibs() else #[]
	}

	def getProject(Resource rs) {
		try {
			val r = workspaceRoot.getFile(new Path(rs.URI.toPlatformString(false)))
			return r.project	
		
	 	}catch(RuntimeException e) {
			//no project associated to resource. 
			//null must be returned
			return null
		}
	} 
	
	def javaProject (Resource resource) {
		val p = resource.project
		if(p !== null) JavaCore.create(p) else null
	}
	
	override getWollokLibs(Resource resource) {
		val javaProject = resource.javaProject
		return resource.paths.map[new ClasspathEntryWollokLib(javaProject, it, manager) as WollokLib]
	}
	

}
