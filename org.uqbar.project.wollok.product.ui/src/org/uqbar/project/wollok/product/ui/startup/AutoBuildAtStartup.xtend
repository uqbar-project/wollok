package org.uqbar.project.wollok.product.ui.startup

import org.eclipse.core.resources.IncrementalProjectBuilder
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.uqbar.project.wollok.ui.WollokUIStartup
import org.uqbar.project.wollok.product.ui.Messages

class AutoBuildAtStartup implements WollokUIStartup {

	override startup() {
		val workspace = ResourcesPlugin.workspace
		val cleanJob = new Job(Messages.AUTO_BUILD_JOB_TITLE) {
			override run(IProgressMonitor monitor) {
				try {
					workspace.build(IncrementalProjectBuilder.FULL_BUILD, monitor)
					return Status.OK_STATUS
				} catch (CoreException ex) {
					return ex.getStatus()
				}
			}
		}
		cleanJob.schedule()
	}

}
