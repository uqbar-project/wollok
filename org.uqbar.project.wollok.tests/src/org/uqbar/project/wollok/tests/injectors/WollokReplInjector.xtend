package org.uqbar.project.wollok.tests.injectors

import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.tests.WollokDslInjectorProvider

class WollokReplInjector extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		val params = new WollokLauncherParameters
		params.hasRepl = true
		new WollokLauncherSetup(params).createInjectorAndDoEMFRegistration
	}
}
