package org.uqbar.project.wollok.tests.injectors

import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

class WollokTestInjector extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		new WollokLauncherSetup().createInjectorAndDoEMFRegistration
	}
}
