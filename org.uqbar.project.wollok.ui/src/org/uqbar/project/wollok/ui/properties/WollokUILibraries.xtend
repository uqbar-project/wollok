package org.uqbar.project.wollok.ui.properties

import javax.inject.Singleton
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.manifest.JarWollokLibraries

import static extension org.uqbar.project.wollok.ui.properties.WollokLibrariesStore.*

@Singleton
class WollokUILibraries extends JarWollokLibraries {

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

}
