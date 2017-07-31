package org.uqbar.project.wollok.tests.injectors

class WollokReplInjector extends WollokTestInjectorProvider {
	
	override protected createParameters() {
		val params = super.createParameters()
		params.hasRepl = true
		params		
	}
	
}
