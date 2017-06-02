package org.uqbar.project.wollok.ui.tests

import java.io.File
import org.eclipse.core.filesystem.EFS
import org.eclipse.core.filesystem.IFileStore
import org.eclipse.core.resources.IProject
import org.eclipse.emf.common.util.URI
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.ide.IDE
import org.eclipse.ui.texteditor.ITextEditor
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ui.util.WorkspaceClasspathUriResolver

import static org.uqbar.project.wollok.WollokConstants.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

@Accessors
abstract class AbstractWollokFileOpenerStrategy {

	public static String CLASSPATH = "classpath:/"

	protected int lineNumber = 0
	protected String fileName = ""
	
	def static AbstractWollokFileOpenerStrategy buildOpenerStrategy(String data, IProject project) {
		if (data.startsWith(CLASSPATH)) {
			new WollokClasspathFileOpenerStrategy(data, project)
		} else {
			new WollokFileOpenerStrategy(data)
		}
	}

	def void initialize(String _data) {
		val data = _data.split(STACKELEMENT_SEPARATOR)
		try {
			fileName = data.get(0)
			lineNumber = new Integer(data.get(1))
		} catch (NumberFormatException e) {
		} catch (Exception e) {
			throw new RuntimeException("Error while opening file " + data, e)
		}
	}

	def ITextEditor getTextEditor(WollokTestResultView view)

}

class WollokClasspathFileOpenerStrategy extends AbstractWollokFileOpenerStrategy {

	IProject project
	
	new(String data, IProject project) {
		this.project = project
		initialize(data)
	}

	override ITextEditor getTextEditor(WollokTestResultView view) {
		val projectName = project.name
		val context = projectName.project
		val URI realURI = new WorkspaceClasspathUriResolver().resolve(context, URI.createURI(fileName))
		view.openElement(realURI) as ITextEditor
	}
}

class WollokFileOpenerStrategy extends AbstractWollokFileOpenerStrategy {

	new(String data) {
		initialize(data)
	}

	override getTextEditor(WollokTestResultView view) {
		val File fileToOpen = new File(fileName)
		val IFileStore fileStore = EFS.getLocalFileSystem().getStore(fileToOpen.toURI)
		val IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
		IDE.openEditorOnFileStore(page, fileStore) as ITextEditor
	}

}
