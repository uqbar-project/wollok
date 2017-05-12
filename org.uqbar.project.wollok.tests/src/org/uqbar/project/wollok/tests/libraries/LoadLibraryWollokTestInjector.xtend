package org.uqbar.project.wollok.tests.libraries

import org.uqbar.project.wollok.tests.WollokDslInjectorProvider
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.launch.WollokLauncherParameters

class LoadLibraryWollokTestInjector extends WollokDslInjectorProvider {

	override protected internalCreateInjector() {
		val params = new WollokLauncherParameters()
		params.libraries.add("wollokLib/pepelib")
		new WollokLauncherSetup(params).createInjectorAndDoEMFRegistration
	}
}