package org.uqbar.project.wollok.utils

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IncrementalProjectBuilder
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IAdaptable
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.JavaCore
import org.eclipse.jface.text.source.IVerticalRuler
import org.eclipse.jface.text.source.IVerticalRulerInfo
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil

/**
 * Utilities on top of eclipse platform.
 * 
 * @author jfernandes 
 */
class WEclipseUtils {
	
	def static <T> T adapt(IAdaptable adaptable, Class<T> toType) { adaptable.getAdapter(toType) as T }
	
	def static openView(String id) {
		PlatformUI.getWorkbench.getActiveWorkbenchWindow.getActivePage.showView(id)
	}
	
	def static schedule(Display display, String message, ()=>void toDo) {
		new Job(message) {
	  		override run(IProgressMonitor monitor) {
	    		toDo.apply
	    		Status.OK_STATUS
	  		}
		}.schedule
	}
	
	def static display(IEditorPart editor) { editor.editorSite.shell.display }

	def static imageDescriptor(String name) { PlatformUI.getWorkbench.getSharedImages.getImageDescriptor(name) }
	
	def static resource(ITextEditor editor) { editor.editorInput.getAdapter(IResource) as IResource }
	
	def static refreshProject(IFile file) {
		file.project.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor)
	}
	
	// **************************
	// ** errors
	// **************************
	
	def static errorStatus(String pluginId, int errorCode, String message, Throwable t) {
		new Status(IStatus.ERROR, pluginId, errorCode, message, t)
	}
	
	def static errorStatus(String pluginId, String message) { new Status(IStatus.ERROR, pluginId, message) }
	
	def static toIFile(URI uri) {
		var path = new Path(uri.toFileString)
		ResourcesPlugin.workspace.root.getFileForLocation(path)
	}
	
	def static toIFile(java.net.URI uri) {
		val path = Path.fromPortableString(uri.toString)
		val file = path.toFile
		var absolutePath = Path.fromOSString(file.absolutePath)
		ResourcesPlugin.workspace.root.getFileForLocation(absolutePath)
	}
	
	def static exists(IPath it) { ResourcesPlugin.getWorkspace.root.exists(it) }
	def static exists(Resource it) {
		if (isWorkspaceOpen && URI.isPlatform)
			iPath.exists
		else {
			val s = URI.toFileString
			s != null && new File(s).exists
		}
	}
	def static iPath(Resource it) { Path.fromOSString(URI.toPlatformString(true)) }
	
	def static getVerticalRuler(XtextEditor editor) { editor.getAdapter(IVerticalRulerInfo) as IVerticalRuler }
	def static getDocument(XtextEditor editor) { XtextDocumentUtil.get(editor) }
	
	def static getFile(EObject obj) {
		ResourcesPlugin.getWorkspace.root.getFile(new Path(obj.eResource.URI.toPlatformString(true)))
	}
	
	def static isWorkspaceOpen() {
		// horrible, but seems the only way (?)
		try {
			ResourcesPlugin.getWorkspace
			true
		}
		catch (IllegalStateException e)
			false 
	}
	
	def static allProjects() { ResourcesPlugin.workspace.root.projects }
	
	def static openProjects() { 
		val root =  ResourcesPlugin.getWorkspace().getRoot()
		root.projects.filter[ project | project.isOpen() && project.hasNature(JavaCore.NATURE_ID)].toList 
	}
	
	def static getProject(String projectName) {
		openProjects.findFirst [ it.name.equalsIgnoreCase(projectName)]	
	}
	
	def static fullBuild(IProject p, IProgressMonitor monitor) {
		p.build(IncrementalProjectBuilder.FULL_BUILD, monitor)
	}
	
	def static asObjectStream(IPath path) { new ObjectOutputStream(new FileOutputStream(path.toOSString)) }
	
	def static <T> readObject(File file, Class<T> type) { file.asObjectInputStream.readObject as T }
	def static asJavaFile(IPath path) { new File(path.toOSString) }
	def static ObjectInputStream asObjectInputStream(File file) { new ObjectInputStream(new FileInputStream(file)) }
	
	def static nameWithoutExtension(IResource it) { if (name.contains(".")) name.substring(0, name.lastIndexOf('.')) else name }
	
}