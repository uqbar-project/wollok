package org.uqbar.project.wollok.ui.libraries

import javax.inject.Singleton
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.manifest.JarWollokLibraries
import org.uqbar.project.wollok.manifest.WollokLib

import static extension org.uqbar.project.wollok.ui.properties.WollokLibrariesStore.*
import org.eclipse.xtext.resource.IResourceDescription.Manager
import com.google.inject.Inject
import org.eclipse.jdt.core.JavaCore
import org.eclipse.core.resources.IProject

@Singleton
class WollokUILibraries extends JarWollokLibraries {

	@Inject
	var Manager manager


	override getPaths(Resource resource) {
		val project = getProject(resource) 
		if(project !== null) project.loadLibs() else #[]
	}

	def getProject(Resource rs) {
		try {
			val r = ResourcesPlugin.workspace.root.getFile(new Path(rs.URI.toPlatformString(false)))
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
