package org.uqbar.project.wollok.ui.console

import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.ObjectInputStream
import java.io.ObjectOutputStream
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

	val lastCommands = new OrderedBoundedSet<String>(10)

	new() {
		super(WollokReplConsole.consoleName, null, Activator.getDefault.getImageDescriptor("icons/w.png"),true);
		this.partitioner = new WollokReplConsolePartitioner(this)
		this.document.documentPartitioner = this.partitioner
	}
	
	def startForProcess(IProcess process) {
		loadHistory
		this.process = process
		this.streamsProxy = process.streamsProxy
		this.activate()
		outputTextEnd = 0;
		

		runInUI[
			this.clearConsole
			DebugUIPlugin.getDefault().getPreferenceStore().setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_OUT, false)
			DebugUIPlugin.getDefault().getPreferenceStore().setValue(IDebugPreferenceConstants.CONSOLE_OPEN_ON_ERR, false)
		]
		
		streamsProxy.outputStreamMonitor.addListener [ text, monitor |
			runInUI("WollokReplConsole-UpdateText")[
				val newText = this.outputText + text
				this.document.set(newText)
				outputTextEnd += text.length 
				this.page.viewer.textWidget.caretOffset = outputTextEnd
				this.updateInputBuffer	
				this.activate
			]
		]
	}
	
	def getOutputText(){
		this.document.get(0, outputTextEnd);
	}
	
	override clearConsole() {
		super.clearConsole()
		this.outputTextEnd = 0
	}
	
	override createPage(IConsoleView view) {
		this.page = new WollokReplConsolePage(this, view)
	}

	static def getConsoleName() {
		"Wollok REPL Console"
	}
		
	def updateInputBuffer(){
		if(outputTextEnd > this.document.length){
			outputTextEnd = this.document.length
		}
		inputBuffer = this.document.get(outputTextEnd, this.document.length - outputTextEnd)
	}
	
	def addCommandToHistory(){
		if(!inputBuffer.empty){
			lastCommands.remove(inputBuffer)
			lastCommands.add(inputBuffer)
			saveHistory()
		}
	}
	
	def saveHistory(){
		runInBackground[
			var file = ResourcesPlugin.workspace.root.location.append(new Path("repl.history"))
			val objStream = new ObjectOutputStream(new FileOutputStream(file.toOSString))
			objStream.writeObject(this.lastCommands)
		]
	}

	def loadHistory(){
		runInBackground[
			var file = ResourcesPlugin.workspace.root.location.append(new Path("repl.history"))
			var javaFile = new File(file.toOSString)
			
			if(javaFile.exists){
				val objStream = new ObjectInputStream(new FileInputStream(javaFile))
				this.lastCommands.clear
				this.lastCommands.addAll(objStream.readObject as OrderedBoundedSet<String>)
			}
		]
	}
	
	def sendInputBuffer(){
		val x = inputBuffer + "\n";
		
		addCommandToHistory
		
		streamsProxy.write(x)
		outputTextEnd += x.length 
		updateInputBuffer
		this.page.viewer.textWidget.caretOffset = outputTextEnd
	}
	
	def numberOfHistories(){ lastCommands.size }
	
	def loadHistory(int pos){
		runInUI[
			inputBuffer = if(lastCommands.size == 0) ""
			else {
				val ps = if(pos >= lastCommands.size) 0 else pos
				lastCommands.last(ps)
			}
			
			val newText = document.get(0, outputTextEnd) + inputBuffer
			document.set(newText)
		]
	}
}

class WollokReplConsolePartitioner implements IConsoleDocumentPartitioner {
	
	val WollokReplConsole console
	
	new(WollokReplConsole console){
		this.console = console
	}
	
	override getStyleRanges(int offset, int length) {
		null
	}
	
	override isReadOnly(int offset) {
		offset < console.outputTextEnd
	}
	
	override computePartitioning(int offset, int length) {
		
	}
	
	override connect(IDocument document) {
	}
	
	override disconnect() {

	}
	
	override documentAboutToBeChanged(DocumentEvent event) {

	}
	
	override documentChanged(DocumentEvent event) {
		true
	}
	
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
