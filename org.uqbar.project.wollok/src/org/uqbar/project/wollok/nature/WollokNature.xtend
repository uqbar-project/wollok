package org.uqbar.project.wollok.nature

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IProjectNature
import org.eclipse.core.runtime.CoreException
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * 
 * @author jfernandes
 */
class WollokNature implements IProjectNature {
	@Accessors
	IProject project
	
	override configure() throws CoreException { }
	
	override deconfigure() throws CoreException { }
	
}