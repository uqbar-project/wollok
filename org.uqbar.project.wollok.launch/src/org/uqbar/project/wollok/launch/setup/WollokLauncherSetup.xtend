package org.uqbar.project.wollok.launch.setup

import com.google.inject.Guice
import org.uqbar.project.wollok.WollokDslStandaloneSetup

class WollokLauncherSetup extends WollokDslStandaloneSetup {

	override createInjector() {
		return Guice.createInjector(new WollokLauncherModule, this);
	}

}
