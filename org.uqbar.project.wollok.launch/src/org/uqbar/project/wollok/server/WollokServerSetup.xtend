package org.uqbar.project.wollok.server

import com.google.inject.Guice
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

/**
 * @author npasserini
 */
class WollokServerSetup extends WollokLauncherSetup {
	
	new(WollokLauncherParameters parameters) {
		super(parameters)
	}

	override createInjector() {
		return Guice.createInjector(new WollokServerModule(params), this);
	}
}