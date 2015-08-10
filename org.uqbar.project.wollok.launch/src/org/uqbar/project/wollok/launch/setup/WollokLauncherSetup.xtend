package org.uqbar.project.wollok.launch.setup

import com.google.inject.Guice
import org.uqbar.project.wollok.WollokDslStandaloneSetup
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import com.google.inject.Binder

class WollokLauncherSetup extends WollokDslStandaloneSetup {

	val WollokLauncherParameters params 

	new(WollokLauncherParameters params) {
		this.params = params
	}
	
	new(){
		this.params = new WollokLauncherParameters
	}

	override createInjector() {
		return Guice.createInjector(new WollokLauncherModule(params), this);
	}

	override configure(Binder binder) {
		super.configure(binder)
		binder.bind(WollokLauncherParameters).toInstance(params)
	}
	
}
