package org.uqbar.project.wollok.ui.tests

import java.io.File
import org.eclipse.core.filesystem.EFS
import org.eclipse.core.filesystem.IFileStore
import org.eclipse.core.resources.IFile
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
	
	def static AbstractWollokFileOpenerStrategy buildOpenerStrategy(String data, IFile testFile) {
		if (data.startsWith(CLASSPATH)) {
			new WollokClasspathFileOpenerStrategy(data, testFile)
		} else {
			new WollokFileOpenerStrategy(data, testFile)
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

	IFile testFile
	
	new(String data, IFile testFile) {
		this.testFile = testFile
		initialize(data)
	}

	override ITextEditor getTextEditor(WollokTestResultView view) {
		val projectName = testFile.project.name
		val context = projectName.project
		val URI realURI = new WorkspaceClasspathUriResolver().resolve(context, URI.createURI(fileName))
		view.openElement(realURI) as ITextEditor
	}
}

class WollokFileOpenerStrategy extends AbstractWollokFileOpenerStrategy {

	new(String data, IFile testFile) {
		initialize(data)
	}

	override getTextEditor(WollokTestResultView view) {
		val File fileToOpen = new File(fileName)
		val IFileStore fileStore = EFS.getLocalFileSystem().getStore(fileToOpen.toURI)
		val IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage()
		IDE.openEditorOnFileStore(page, fileStore) as ITextEditor
	}

}
