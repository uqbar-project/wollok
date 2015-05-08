package org.uqbar.project.wollok.ui.debugger.client.source

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.sourcelookup.ISourceContainer
import org.eclipse.debug.core.sourcelookup.ISourcePathComputerDelegate
import org.eclipse.debug.core.sourcelookup.containers.FolderSourceContainer
import org.eclipse.debug.core.sourcelookup.containers.ProjectSourceContainer
import org.eclipse.debug.core.sourcelookup.containers.WorkspaceSourceContainer
import org.uqbar.project.wollok.launch.WollokLaunchConstants

/**
 * 
 * @author jfernandes
 */
class WollokSourcePathComputer implements ISourcePathComputerDelegate {
	
	//horrible copiado de PDA
	override computeSourceContainers(ILaunchConfiguration configuration, IProgressMonitor monitor) throws CoreException {
		val path = configuration.getAttribute(WollokLaunchConstants.ID_DEBUG_MODEL, null as String)
		var ISourceContainer sourceContainer = null
		if (path != null) {
			val resource = ResourcesPlugin.workspace.root.findMember(new Path(path))
			if (resource != null) {
				val container = resource.parent
				if (container.type == IResource.PROJECT) {
					sourceContainer = new ProjectSourceContainer(container as IProject, false);
				} else if (container.type == IResource.FOLDER) {
					sourceContainer = new FolderSourceContainer(container, false)
				}
			}
		}
		if (sourceContainer == null)
			sourceContainer = new WorkspaceSourceContainer
		return #[sourceContainer]
	}
	
}