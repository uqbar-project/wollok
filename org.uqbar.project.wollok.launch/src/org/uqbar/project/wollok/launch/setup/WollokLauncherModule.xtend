package org.uqbar.project.wollok.launch.setup

import org.uqbar.project.wollok.WollokDslRuntimeModule
import org.uqbar.project.wollok.scoping.WollokReplGlobalScopeProvider

class WollokLauncherModule extends WollokDslRuntimeModule {
	override bindIGlobalScopeProvider() {
		return WollokReplGlobalScopeProvider
	}
}
