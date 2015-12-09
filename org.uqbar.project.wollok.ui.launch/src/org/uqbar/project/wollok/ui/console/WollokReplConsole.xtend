package org.uqbar.project.wollok.ui.console

import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.core.model.IStreamsProxy
import org.eclipse.debug.internal.ui.DebugUIPlugin
import org.eclipse.debug.internal.ui.preferences.IDebugPreferenceConstants
import org.eclipse.jface.text.DocumentEvent
import org.eclipse.jface.text.IDocument
import org.eclipse.ui.console.IConsoleDocumentPartitioner
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsole
import org.eclipse.ui.console.TextConsolePage
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.tools.OrderedBoundedSet
import org.uqbar.project.wollok.ui.launch.Activator

import static org.uqbar.project.wollok.ui.console.RunInBackground.*
import static org.uqbar.project.wollok.ui.console.RunInUI.*

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import java.util.List
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut
import org.eclipse.core.resources.IFile
import java.io.InputStream
import java.io.ByteArrayInputStream
import java.io.File
import org.eclipse.core.resources.IContainer
import java.util.Date
import java.text.SimpleDateFormat

/**
 * @author tesonep
 */
class WollokReplConsole extends TextConsole {
	IProcess process
	IStreamsProxy streamsProxy
	@Accessors
	TextConsolePage page
	@Accessors
	int outputTextEnd = 0
	@Accessors
	String inputBuffer = ""
	@Accessors
	WollokReplConsolePartitioner partitioner
	@Accessors
	List<String> sessionCommands = newArrayList

	val lastCommands = new OrderedBoundedSet<String>(10)

	def static getConsoleName() { "Wollok REPL Console" }

	new() {
		super(consoleName, null, Activator.getDefault.getImageDescriptor("icons/w.png"), true)
		this.partitioner = new WollokReplConsolePartitioner(this)
		this.document.documentPartitioner = this.partitioner
	}
	
	def startForProcess(IProcess process) {
		loadHistory
		this.process = process
		streamsProxy = process.streamsProxy
		activate
		outputTextEnd = 0
		
		runInUI[
			clearConsole
			DebugUIPlugin.getDefault.preferenceStore.setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_OUT, false)
			DebugUIPlugin.getDefault.preferenceStore.setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_ERR, false)
		]
		
		streamsProxy.outputStreamMonitor.addListener [ text, monitor |
			runInUI("WollokReplConsole-UpdateText") [
				page.viewer.textWidget.append(text)
				outputTextEnd += text.length
				page.viewer.textWidget.caretOffset = outputTextEnd
				updateInputBuffer
				activate
			]
		]
	}
	
	def shutdown() { process.terminate }
	def isRunning() { !process.terminated }
	
	def getOutputText() { document.get(0, outputTextEnd) }
	
	override clearConsole() {
		super.clearConsole
		outputTextEnd = 0
	}
	
	override createPage(IConsoleView view) {
		this.page = new WollokReplConsolePage(this, view) => [
			setFocus
		]
	}
	
	def exportSession() {
		val fileName = WollokLaunchShortcut.getWollokFile(process.launch)
		val project = WollokLaunchShortcut.getWollokProject(process.launch)
		println("Exporting from project " + project + " and file " + fileName)
		val file = (ResourcesPlugin.getWorkspace.root.findMember(project) as IContainer).findMember(fileName)
		val newFile = file.parent.getFile(new Path(file.nameWithoutExtension + ".wtest"))

		// TODO include same imports as original file		
		val content = '''
			import «file.nameWithoutExtension».*
			
			// auto-generated at «new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date())»
			test "exported test from REPL session" {
				
				«FOR s : sessionCommands»
					«s»
				«ENDFOR»
				
			}
		'''.toString
		newFile.create(new ByteArrayInputStream(content.bytes), false, null)
	}

	def updateInputBuffer() {
		if (outputTextEnd > document.length) {
			outputTextEnd = document.length
		}
		inputBuffer = document.get(outputTextEnd, document.length - outputTextEnd)
	}
	
	def addCommandToHistory() {
		if (!inputBuffer.empty) {
			lastCommands => [
				remove(inputBuffer)
				add(inputBuffer)
			]
			saveHistory
		}
	}
	
	def saveHistory() {
		runInBackground [
			historyFilePath.asObjectStream.writeObject(lastCommands)
		]
	}

	def loadHistory() {
		runInBackground [
			val javaFile = historyFilePath.asJavaFile
			
			if (javaFile.exists) {
				lastCommands => [
					clear
					addAll(javaFile.asObjectInputStream.readObject as OrderedBoundedSet<String>)
				]
			}
		]
	}
	
	def historyFilePath() {
		ResourcesPlugin.workspace.root.location.append(new Path("repl.history"))
	}
	
	def sendInputBuffer() {
		val x = inputBuffer + "\n";
		
		addCommandToHistory
		sessionCommands += inputBuffer
		
		streamsProxy.write(x)
		outputTextEnd += x.length
		updateInputBuffer
		page.viewer.textWidget.caretOffset = outputTextEnd
	}
	
	def numberOfHistories() { lastCommands.size }
	
	def loadHistory(int pos) {
		runInUI [
			inputBuffer = if (lastCommands.size == 0) ""
			else {
				val ps = if (pos >= lastCommands.size) 0 else pos
				lastCommands.last(ps)
			}
			
			page.viewer.textWidget.content.replaceTextRange(outputTextEnd, document.length - outputTextEnd, inputBuffer)
		]
	}
	
	def canWriteAt(int offset) { partitioner.isReadOnly(offset) }
	
}

class WollokReplConsolePartitioner implements IConsoleDocumentPartitioner {
	val WollokReplConsole console
	
	new(WollokReplConsole console) {
		this.console = console
	}
	
	override getStyleRanges(int offset, int length) { null }
	
	override isReadOnly(int offset) { offset < console.outputTextEnd }
	
	override computePartitioning(int offset, int length) { }
	
	override connect(IDocument document) { }
	
	override disconnect() { }
	
	override documentAboutToBeChanged(DocumentEvent event) { }
	
	override documentChanged(DocumentEvent event) { true }
	
	override getContentType(int offset) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getLegalContentTypes() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	override getPartition(int offset) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}
