package org.uqbar.project.wollok.tests.injectors

import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.tests.WollokDslInjectorProvider

class WollokTestInjector extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		new WollokLauncherSetup().createInjectorAndDoEMFRegistration
	}
}
