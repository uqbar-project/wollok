package org.uqbar.project.wollok.ui.console

import java.io.ByteArrayInputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.List
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.core.model.IStreamsProxy
import org.eclipse.debug.internal.ui.DebugUIPlugin
import org.eclipse.debug.internal.ui.preferences.IDebugPreferenceConstants
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsole
import org.eclipse.ui.console.TextConsolePage
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.tools.OrderedBoundedSet
import org.uqbar.project.wollok.ui.console.editor.WollokReplConsolePartitioner
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut

import static org.uqbar.project.wollok.ui.console.RunInBackground.*
import static org.uqbar.project.wollok.ui.console.RunInUI.*

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

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
	int inputBufferStartOffset = 0
	@Accessors
	String inputBuffer = ""
	@Accessors
	WollokReplConsolePartitioner partitioner
	@Accessors
	List<String> sessionCommands = newArrayList
	@Accessors
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

		runInUI [
			clearConsole
			DebugUIPlugin.getDefault.preferenceStore.setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_OUT, false)
			DebugUIPlugin.getDefault.preferenceStore.setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_ERR, false)
			
		]

		streamsProxy.outputStreamMonitor.addListener [ text, monitor |
			runInUI("WollokReplConsole-UpdateText") [
				page.viewer.textWidget.append(text)
				outputTextEnd = page.viewer.textWidget.charCount
				inputBufferStartOffset = page.viewer.textWidget.text.length
				page.viewer.textWidget.selection = outputTextEnd
				updateInputBuffer
				activate
			]
		]
	}

	def cleanViewOfConsole() {
		val wordToWrite = "/^*^?/" + System.lineSeparator
		clearConsole
		streamsProxy.write(wordToWrite)
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
			name = consoleDescription
		]
	}
	
	def consoleDescription() {
		consoleName + if (hasMainFile)  ": " + project() + "/" + fileName() else  ""
	}
	
	def hasMainFile() {
		return fileName() !== null && fileName.endsWith(".wlk")
	}

	def fileName() {
		WollokLaunchShortcut.getWollokFile(process.launch)
	}
	
	def project() {
		WollokLaunchShortcut.getWollokProject(process.launch)
	}

	def exportSession() {
		val fileName = fileName()
		val project = project()
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
		addCommandToHistory
		sessionCommands += inputBuffer
		streamsProxy.write(inputBuffer) 
		outputTextEnd = page.viewer.textWidget.charCount
		updateInputBuffer
		page.viewer.textWidget.selection = outputTextEnd
	}

	def numberOfHistories() { lastCommands.size }

	def loadHistory(int pos) {
		runInUI [
			inputBuffer = if (lastCommands.size == 0)
				""
			else {
				val ps = if(pos >= lastCommands.size) 0 else pos
				lastCommands.last(ps)
			}

			page.viewer.textWidget.content.replaceTextRange(outputTextEnd, document.length - outputTextEnd, inputBuffer)
		]
	}

	def canWriteAt(int offset) { !partitioner.isReadOnly(offset) }

	def void updateIfDirty() {
		if (inputBuffer.empty) {
			updateInputBuffer
			// hack - delete all RETURN keys to avoid several >>> 
			inputBuffer = inputBuffer.replaceAll(System.lineSeparator, '')
		}
	}
}
