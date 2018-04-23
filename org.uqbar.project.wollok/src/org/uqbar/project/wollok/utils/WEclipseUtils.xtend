package org.uqbar.project.wollok.utils

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
import java.util.Map
import java.util.Set
import org.eclipse.core.internal.resources.Project
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IMarker
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
import org.eclipse.jdt.internal.core.JavaProject
import org.eclipse.jface.text.BadLocationException
import org.eclipse.jface.text.IDocument
import org.eclipse.jface.text.IRegion
import org.eclipse.jface.text.source.IVerticalRuler
import org.eclipse.jface.text.source.IVerticalRulerInfo
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.IEditorPart
import org.eclipse.ui.IPageLayout
import org.eclipse.ui.PartInitException
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.model.XtextDocumentUtil

import static org.uqbar.project.wollok.WollokConstants.*

/**
 * Utilities on top of eclipse platform.
 * 
 * @author jfernandes 
 */
class WEclipseUtils {

	def static <T> T adapt(IAdaptable adaptable, Class<T> toType) { adaptable.getAdapter(toType) as T }

	def static openView(String id) {
		activePage.showView(id)
	}

	def static activePage() {
		PlatformUI.getWorkbench.getActiveWorkbenchWindow.getActivePage
	}

	def static findView(String id) {
		activePage.findView(id)
	}

	def static getProjectExplorer() {
		findView(IPageLayout.ID_PROJECT_EXPLORER)
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

	def static refreshProject(EObject e) {
		e.file.refreshProject
	}

	def static refreshProject(IResource resource) {
		resource.project?.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor)
	}

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

	def static toIFile(EObject o) {
		o.eResource.URI.toIFile
	}

	def static getProject(EObject o) {
		o.toIFile.project
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
			s !== null && new File(s).exists
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
		} catch (IllegalStateException e)
			false
	}

	def static allProjects() { ResourcesPlugin.workspace.root.projects }

	def static openProjects() {
		val root = ResourcesPlugin.getWorkspace().getRoot()
		root.projects.filter[project|project.isOpen() && project.hasNature(JavaCore.NATURE_ID)].toList
	}

	def static getProject(String projectName) {
		openProjects.findFirst[it.name.equalsIgnoreCase(projectName)]
	}

	def static fullBuild(IProject p, IProgressMonitor monitor) {
		p.build(IncrementalProjectBuilder.FULL_BUILD, monitor)
	}

	def static asObjectStream(IPath path) { new ObjectOutputStream(new FileOutputStream(path.toOSString)) }

	def static <T> readObject(File file, Class<T> type) { file.asObjectInputStream.readObject as T }

	def static asJavaFile(IPath path) { new File(path.toOSString) }

	def static ObjectInputStream asObjectInputStream(File file) { new ObjectInputStream(new FileInputStream(file)) }

	def static nameWithoutExtension(IResource it) {
		if(name.contains(".")) name.substring(0, name.lastIndexOf('.')) else name
	}

	def static openEditor(ITextEditor textEditor, String fileName, int lineNumber) {
		try {
			val IDocument document = textEditor.documentProvider.getDocument(textEditor.editorInput)
			if(document === null) throw new RuntimeException("Could not open file " + fileName + " in editor")
			var IRegion lineInfo = null
			// line count internaly starts with 0, and not with 1 like in GUI
			lineInfo = document.getLineInformation(lineNumber - 1)
			if (lineInfo !== null) {
				textEditor.selectAndReveal(lineInfo.getOffset(), lineInfo.getLength())
			}
		} catch (BadLocationException e) {
			// ignored because line number may not really exist in document,
			// we guess this...
		} catch (PartInitException e) {
			e.printStackTrace
		}
	}

	def static dispatch Set<IResource> getAllMembers(IContainer container) {
		val Map<String, IResource> result = newHashMap
		container.members.filter[fullPath.toPortableString.contains(SOURCE_FOLDER)].forEach [
			allMembers.forEach[result.put(it.fullPath.toPortableString, it)]
		]
		result.values.toSet
	}

	def static dispatch Set<IResource> getAllMembers(IFile file) {
		#{file}
	}

	def static hasErrors(IProject project) {
		val severity = project.findMaxProblemSeverity(IMarker.PROBLEM, true, IResource.DEPTH_INFINITE)
		severity == IMarker.SEVERITY_ERROR
	}

	def static allWollokFiles(IProject project) {
		project.allMembers.filter[isWollokExtension].map[convertToEclipseURI].toList
	}

	def static convertToEclipseURI(IResource res) {
		URI.createFileURI(res.locationURI.rawPath.toString.replaceAll("%20", " "))
	}

	def static isWollokExtension(IResource file) {
		#[PROGRAM_EXTENSION, TEST_EXTENSION, CLASS_OBJECTS_EXTENSION].contains(file.fileExtension)
	}

	def static dispatch String getFullPath(Object o) { "" }

	def static dispatch String getFullPath(JavaProject p) {
		val firstSourceFolder = if (p.allPackageFragmentRoots.empty) "" else p.allPackageFragmentRoots.head?.resource.name
		p.forceSourceFolderPath(firstSourceFolder)
	}

	def static dispatch String getFullPath(Project p) {
		p.forceSourceFolderPath(SOURCE_FOLDER)		
	}
	
	def static dispatch getFullPath(IResource r) {
		r.path
	}

	def static dispatch getFullPath(IAdaptable a) {
		a.getAdapter(typeof(IResource)).path
	}

	def static forceSourceFolderPath(IAdaptable project, String sourceFolder) {
		var newPath = project.getAdapter(typeof(IResource)).path
		if (!newPath.endsWith(sourceFolder)) {
			newPath += "/" + sourceFolder
		}
		newPath
	}

	def static String getPath(IResource r) {
		var resource = r
		if (resource.getType() === IResource.FILE) {
			resource = resource.parent
		}
		if (resource.isAccessible()) {
			return resource.fullPath.toString()
		}
		return ""
	}
	
	def static dispatch IContainer getContainer(Project p) {
		var resource = p.getAdapter(typeof(IResource))
		if (!resource.path.endsWith(SOURCE_FOLDER)) {
			resource = p.findMember(SOURCE_FOLDER)
		}
		resource.container
	}

	def static dispatch IContainer getContainer(JavaProject p) {
		if (p.allPackageFragmentRoots.empty) {
			return null
		} 
		p.allPackageFragmentRoots.head?.resource.container
	}
	
	def static dispatch IContainer getContainer(IContainer c) { c }
	
	def static dispatch IContainer getContainer(IResource r) { r.parent }

	def static dispatch IContainer getContainer(Object o) { null }
	
	def static boolean isSourceFolder(IResource r) {
		HIDDEN_FOLDERS.forall [ !r.path.contains("/" + it) ]
	}

}
