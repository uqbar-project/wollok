package org.uqbar.project.wollok.tests.libraries

import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

class LoadLibraryWollokTestInjector extends WollokTestInjectorProvider {

	override protected createParameters() {
		val params = super.createParameters()
		params.libraries.add("wollokLib/libfortest.jar")
		params
	}
	
}
