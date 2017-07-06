package org.uqbar.project.wollok.ui.console

import org.eclipse.ui.console.IHyperlink
import org.eclipse.ui.console.IPatternMatchListenerDelegate
import org.eclipse.ui.console.PatternMatchEvent
import org.eclipse.ui.console.TextConsole
import org.eclipse.xtext.ui.editor.IURIEditorOpener
import org.uqbar.project.wollok.ui.WollokActivator
import org.uqbar.project.wollok.ui.tests.AbstractWollokFileOpenerStrategy

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

class WollokLinkListenerDelegate implements IPatternMatchListenerDelegate {

	var IURIEditorOpener opener
	
	TextConsole console
	
	override connect(TextConsole console) {
		this.console = console
		this.opener = WollokActivator.getInstance.opener
	}
	
	override disconnect() {
		this.console = null
	}
	
	override matchFound(PatternMatchEvent event) {
		try	{
			// Deletes first character, opening parentheses
			val fileReferenceText = console.document.get(event.offset + 1, event.length - 1)
			val hyperlink = makeHyperlink(fileReferenceText, opener) // a link to any file
			console.addHyperlink(hyperlink, event.offset, event.length)
		} catch (Exception exception) {
			throw new RuntimeException(exception)
		}
	}
	
	def static IHyperlink makeHyperlink(String fileReferenceText, IURIEditorOpener opener) {
		return new IHyperlink()	{

			override linkExited() {	}

			override linkEntered() { }

			override linkActivated() {
				try {
					val project = openProjects.head
					val fileOpenerStrategy = AbstractWollokFileOpenerStrategy.buildOpenerStrategy(fileReferenceText, project)
					val textEditor = fileOpenerStrategy.getTextEditor(opener)
					val fileName = fileOpenerStrategy.fileName
					val Integer lineNumber = fileOpenerStrategy.lineNumber
					textEditor.openEditor(fileName, lineNumber)
				}
				catch (Exception exception)	{
					throw new RuntimeException(exception)
				}
			}
		}
	}

}