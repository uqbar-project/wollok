package org.uqbar.project.wollok.nature

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IProjectNature
import org.eclipse.core.runtime.CoreException

/**
 * 
 * @author jfernandes
 */
class WollokNature implements IProjectNature {
	@Property IProject project
	
	override configure() throws CoreException { }
	
	override deconfigure() throws CoreException { }
	
}