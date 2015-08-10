package org.uqbar.project.wollok.ui.tests

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.io.IOUtils
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier

class WollokTestsResultListener {
	val Server server
	val CallHandler callHandler
	
	@Accessors
	val WollokUITestNotifier wollokUITestNotifier
	
	@Accessors
	val int listeningPort

	new() {
		wollokUITestNotifier = new WollokUITestNotifier

		callHandler = new CallHandler
		callHandler.registerGlobal(WollokRemoteUITestNotifier, wollokUITestNotifier)

		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort, callHandler)
	}
	
	def close(){
		server.close()
	}
}
