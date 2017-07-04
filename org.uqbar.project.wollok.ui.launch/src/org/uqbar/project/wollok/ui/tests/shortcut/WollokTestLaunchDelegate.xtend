package org.uqbar.project.wollok.ui.tests.shortcut

import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.debug.core.ILaunch
import org.eclipse.debug.core.ILaunchConfiguration
import org.uqbar.project.wollok.ui.launch.Activator
import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchDelegate
import org.uqbar.project.wollok.ui.tests.WollokTestResultView

/**
 * @author tesonep
 */
class WollokTestLaunchDelegate extends WollokLaunchDelegate {
	
	override launch(ILaunchConfiguration configuration, String mode, ILaunch launch, IProgressMonitor monitor) throws CoreException {
		WollokTestResultView.activate()
		super.launch(configuration, mode, launch, monitor)
	}
	
	override configureLaunchParameters(ILaunchConfiguration config, int requestPort, int eventPort) {
		super.configureLaunchParameters(config, requestPort, eventPort) => [
			tests = true
			testPort = Activator.getDefault.wollokTestViewListeningPort
		]
	}
	
}