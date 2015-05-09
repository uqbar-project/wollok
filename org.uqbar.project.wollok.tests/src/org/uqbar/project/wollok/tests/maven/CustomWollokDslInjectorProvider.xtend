package org.uqbar.project.wollok.tests.maven

import com.google.inject.Guice
import org.uqbar.project.wollok.WollokDslInjectorProvider
import org.uqbar.project.wollok.WollokDslRuntimeModule
import org.uqbar.project.wollok.WollokDslStandaloneSetup

class CustomWollokDslInjectorProvider extends WollokDslInjectorProvider {
	
	override internalCreateInjector() {
		new WollokDslStandaloneSetup() {
			override createInjector() {
				Guice.createInjector(new WollokDslRuntimeModule() {
					override bindWollokManifestFinder() {
						WollokJDTManifestFinder
					}
					
				}, this);
			}
		}.createInjectorAndDoEMFRegistration
	}
	
}