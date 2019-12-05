package org.uqbar.project.wollok.tests.injectors

import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.tests.WollokDslInjectorProvider

class WollokTestInjectorProvider extends WollokDslInjectorProvider {
	
	override protected internalCreateInjector() {
		val params = createParameters
		new WollokTestSetup(params).createInjectorAndDoEMFRegistration
	}
	
	def protected createParameters() {
		new WollokLauncherParameters
	}
}

class WollokSanityTestInjectorProvider extends WollokTestInjectorProvider {
	
	override createParameters() {
		new WollokLauncherParameters => [
			severalFiles = true
			tests = true
			jsonOutput = false
			exitOnBuildFailure = false
			colored = false
		]
	}
}
