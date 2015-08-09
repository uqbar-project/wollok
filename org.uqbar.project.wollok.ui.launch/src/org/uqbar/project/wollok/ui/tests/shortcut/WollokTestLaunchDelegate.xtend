package org.uqbar.project.wollok.ui.tests.shortcut

import org.uqbar.project.wollok.ui.launch.shortcut.WollokLaunchDelegate
import org.eclipse.debug.core.ILaunchConfiguration
import org.uqbar.project.wollok.ui.tests.WollokTestResultView

class WollokTestLaunchDelegate extends WollokLaunchDelegate {
	
	override configureLaunchParameters(ILaunchConfiguration config, int requestPort, int eventPort) {
		val cfg = super.configureLaunchParameters(config, requestPort, eventPort)
		cfg.tests = true
		cfg.testPort = WollokTestResultView.view.listeningPort
		cfg
	}
}