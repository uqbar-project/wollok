package org.uqbar.project.wollok.ui.console

import java.io.ByteArrayInputStream
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.Date
import java.util.List
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.debug.core.ILaunchConfiguration
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.core.model.IStreamsProxy
import org.eclipse.debug.internal.ui.DebugUIPlugin
import org.eclipse.debug.internal.ui.preferences.IDebugPreferenceConstants
import org.eclipse.debug.ui.DebugUITools
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.widgets.Display
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.TextConsole
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.tools.OrderedBoundedSet
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.console.actions.WollokReplConsoleActionsParticipant
import org.uqbar.project.wollok.ui.console.editor.WollokReplConsolePartitioner
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchShortcut

import static org.uqbar.project.wollok.WollokConstants.*
import static org.uqbar.project.wollok.ui.console.RunInBackground.*
import static org.uqbar.project.wollok.ui.console.RunInUI.*
import static org.uqbar.project.wollok.ui.i18n.WollokLaunchUIMessages.*

import static extension org.uqbar.project.wollok.ui.launch.WollokLaunchConstants.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * @author tesonep
 */
class WollokReplConsole extends TextConsole {
	IProcess process
	IStreamsProxy streamsProxy
	@Accessors
	WollokReplConsolePage page
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
	val lastCommands = new OrderedBoundedSet<String>(30)
	List<String> lastSessionCommands
	List<String> lastSessionCommandsToRun
	@Accessors(PUBLIC_GETTER)
	Long timeStart
	boolean running = true
	List<WollokReplConsoleActionsParticipant> wollokActionsParticipants = newArrayList

	static Color ENABLED_LIGHT = new Color(Display.current, 255, 255, 255)
	static Color DISABLED_LIGHT = new Color(Display.current, 220, 220, 220)
	static Color ENABLED_DARK = new Color(Display.current, 26, 26, 26)
	static Color DISABLED_DARK = new Color(Display.current, 89, 89, 89)

	ILaunchConfiguration configuration
	String mode

	boolean restartingLastSession = false
	
	@Accessors(PUBLIC_GETTER)
	boolean noAnsiFormat = false

	def static getConsoleName() { "Wollok REPL Console" }

	new(ILaunchConfiguration configuration, boolean noAnsiFormat, String mode) {
		super(consoleName, null, Activator.getDefault.getImageDescriptor("icons/w.png"), true)
		this.background = backgroundEnabled
		this.partitioner = new WollokReplConsolePartitioner(this)
		this.document.documentPartitioner = this.partitioner

		// Parameters needed to restart the console
		this.configuration = configuration
		this.mode = mode
		this.restartingLastSession = configuration.restartingState
		this.lastSessionCommandsToRun = configuration.lastCommands
		this.noAnsiFormat = noAnsiFormat
	}

	def startForProcess(IProcess process) {
		timeStart = System.currentTimeMillis
		lastSessionCommands = newArrayList
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
				if (page !== null && page.viewer !== null && page.viewer.textWidget !== null) {
					text.processInput
					val promptReady = text.contains(REPL_PROMPT)
					if (this.restartingLastSession && promptReady && !this.lastSessionCommandsToRun.isEmpty) {
						val nextCommand = this.lastSessionCommandsToRun.remove(0)
						nextCommand.execute
					}
				}
			]
		]
	}
	
	def addWollokActionsParticipant(WollokReplConsoleActionsParticipant participant) {
		this.wollokActionsParticipants.add(participant)
	}

	def processInput(String text) {
		page.viewer.textWidget.append(text)
		outputTextEnd = page.viewer.textWidget.charCount
		inputBufferStartOffset = page.viewer.textWidget.text.length
		page.viewer.textWidget.selection = outputTextEnd
		updateInputBuffer
		if (text.contains(REPL_END)) {
			this.shutdown
			this.wollokActionsParticipants.forEach [ activated ]
		}
		activate
	}

	def restart() {
		DebugUITools.launch(this.configuration, this.mode)
	}

	def restartLastSession() {
		val newConfiguration = this.configuration.getWorkingCopy => [
			setRestartingState(true)
			setLastCommands(new ArrayList(lastSessionCommands))
		]
		DebugUITools.launch(newConfiguration, this.mode)
	}

	def synchronized void execute(String command) {
		runInUI [
			inputBuffer = command
			page.viewer.textWidget.content.replaceTextRange(outputTextEnd, document.length - outputTextEnd, inputBuffer)
			page.setCursorToEnd
			sendInputBuffer
		]
	}

	def cleanViewOfConsole() {
		val wordToWrite = "/^*^?/" + System.lineSeparator
		clearConsole
		streamsProxy.write(wordToWrite)
	}

	def shutdown() {
		background = backgroundDisabled
		running = false
		process.terminate
	}

	def isRunning() {
		if (!running) {
			background = backgroundDisabled
		}
		running
	}

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
		consoleName + if(hasMainFile) ": " + project() + "/" + fileName() else ""
	}

	def hasMainFile() {
		return fileName() !== null && fileName.endsWith("." + WollokConstants.WOLLOK_DEFINITION_EXTENSION)
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
		val newFile = file.parent.getFile(new Path(file.nameWithoutExtension + "." + WollokConstants.TEST_EXTENSION))

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
		if (!inputBuffer.trim.empty) {
			lastCommands => [
				remove(inputBuffer)
				add(inputBuffer)
			]
			lastSessionCommands.add(inputBuffer)
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
			page.viewer.textWidget.content.replaceTextRange(outputTextEnd, document.length - outputTextEnd,
				inputBuffer.replace(System.lineSeparator, ""))
		]
	}

	def clearHistory() { lastCommands.clear }

	def canWriteAt(int offset) { !partitioner.isReadOnly(offset) }

	def void updateIfDirty() {
		if (inputBuffer.empty) {
			updateInputBuffer
			// hack - delete all RETURN keys to avoid several >>> 
			inputBuffer = inputBuffer.replaceAll(System.lineSeparator, '')
		}
	}

	def backgroundEnabled() {
		if (environmentHasDarkTheme) ENABLED_DARK else ENABLED_LIGHT
	}
	
	def backgroundDisabled() {
		if (environmentHasDarkTheme) DISABLED_DARK else DISABLED_LIGHT
	}
}
