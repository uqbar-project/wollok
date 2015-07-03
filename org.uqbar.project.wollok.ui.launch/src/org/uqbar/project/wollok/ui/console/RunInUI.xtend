package org.uqbar.project.wollok.ui.console

import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.ui.progress.UIJob
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0

class RunInUI extends UIJob {

	Procedure0 block

	new(String name, Procedure0 closure) {
		super(ConsolePlugin.getStandardDisplay(), name)
		this.block = closure
	}

	override runInUIThread(IProgressMonitor monitor) {
		block.apply()
		return Status.OK_STATUS
	}

	def static runInUI(Procedure0 block){
		runInUI("",block)
	}
	
	def static runInUI(String name,Procedure0 block){
		new RunInUI(name, block).schedule
	}

}
