package org.uqbar.project.wollok.server

import org.uqbar.project.wollok.interpreter.WollokInterpreterConsole
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherModule

/**
 * @author npasserini
 */
class WollokServerModule extends WollokLauncherModule {
	new(WollokLauncherParameters params) {
		super(params)
	}

	override Class<? extends WollokInterpreterConsole> bindWollokInterpreterConsole() {
		WollokServerConsole
	}

}
