package org.uqbar.project.wollok.ui.launch.extensions

import org.eclipse.debug.ui.console.IConsole
import org.uqbar.project.wollok.ui.console.RunInUI
import org.uqbar.project.wollok.ui.console.WollokReplConsole

class WollokConsoleExtensions {
	
	def static dispatch shutdown(IConsole console) {}
	
	def static dispatch shutdown(WollokReplConsole console) {
		RunInUI.runInUI [
			console.shutdown
		]
	}
}