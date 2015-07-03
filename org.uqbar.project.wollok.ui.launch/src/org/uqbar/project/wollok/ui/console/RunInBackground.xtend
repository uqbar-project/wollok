package org.uqbar.project.wollok.ui.console

import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0

class RunInBackground extends Job {

	Procedure0 block

	new(String name, Procedure0 closure) {
		super(name)
		this.block = closure
	}

	override protected run(IProgressMonitor monitor) {
		block.apply()
		return Status.OK_STATUS
	}

	def static runInBackground(Procedure0 block){
		runInBackground("",block)
	}
	
	def static runInBackground(String name,Procedure0 block){
		new RunInBackground(name, block).schedule
	}
}
