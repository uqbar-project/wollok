package org.uqbar.project.wollok.ui.utils

import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.jdt.core.IJavaProject
import org.eclipse.jdt.core.JavaCore

/**
 * Utilities for IDE projects and files manipulation
 */
class IDEUtils {
	
	def static getWorkspaceRoot() {
		ResourcesPlugin.workspace.root
	}
	
	def static getOpenProjects() {
		workspaceRoot.projects.filter[ project | project.open && project.hasNature(JavaCore.NATURE_ID)]
	}
	
	def static IProject getCurrentProject() {
		var IProject project
		if (openProjects.isEmpty) {
			// TODO, Vemos de donde lo sacamos
			// o generamos uno
		} else {
			project = openProjects.head
		}
		project
	}

	def static IJavaProject getCurrentJavaProject() {
		JavaCore.create(currentProject)
	}	
}