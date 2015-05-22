package org.uqbar.project.wollok.ui.console

import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.debug.core.model.IProcess
import org.eclipse.debug.core.model.IStreamsProxy
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.ui.console.IConsoleView
import org.eclipse.ui.console.IOConsole
import org.eclipse.ui.console.IOConsoleInputStream
import org.eclipse.ui.console.IOConsoleOutputStream
import org.eclipse.ui.console.TextConsolePage
import org.eclipse.ui.progress.UIJob
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator
import java.io.IOException

class WollokReplConsole extends IOConsole {

	IProcess process
	IStreamsProxy streamsProxy
	IOConsoleOutputStream outputStream;
	IConsoleView consoleView
	@Accessors
	TextConsolePage page

	new() {
		super(WollokReplConsole.consoleName, Activator.getDefault.getImageDescriptor("icons/w.png"));
		this.outputStream = this.newOutputStream
	}
	
	def startForProcess(IProcess process) {
		this.clearConsole
		this.process = process
		this.streamsProxy = process.streamsProxy
		this.activate

		streamsProxy.outputStreamMonitor.addListener [ text, monitor |
			outputStream.write(text)
			if (this.page != null) {
				new SetFocusInConsoleJob(this).schedule(100)
			}
			this.activate
		]
		
		new SteamCopyJob(inputStream, streamsProxy).schedule
	}
	
	override createPage(IConsoleView view) {
		this.consoleView = view;
		this.page = super.createPage(view) as TextConsolePage
	}

	static def getConsoleName() {
		"Wollok REPL Console"
	}
}

class SteamCopyJob extends Job {

	var IOConsoleInputStream in
	var IStreamsProxy out

	new(IOConsoleInputStream in, IStreamsProxy out) {
		super("Copy Stream for WollokRepl")
		this.priority = SHORT
		this.system = true
		this.in = in
		this.out = out
	}

	override protected run(IProgressMonitor monitor) {
		var b = newByteArrayOfSize(1024)
		var read = 0;
		try{
			while (in != null && read >= 0) {
				read = in.read(b);
				if (read > 0) {
					var s = new String(b, 0, read);
					out.write(s);
				}
			}
		}catch(IOException e){
			// if the underlying stream is closed the job has to end gracefully. 
		}
		
		Status.OK_STATUS
	}
}

class SetFocusInConsoleJob extends UIJob {

	WollokReplConsole console

	new(WollokReplConsole console) {
		super(ConsolePlugin.getStandardDisplay(), "SetFocusRepl")
		this.console = console
	}

	override runInUIThread(IProgressMonitor monitor) {
		console.page.setFocus
		console.page.viewer.textWidget.caretOffset = console.document.length
		return Status.OK_STATUS;
	}

}
