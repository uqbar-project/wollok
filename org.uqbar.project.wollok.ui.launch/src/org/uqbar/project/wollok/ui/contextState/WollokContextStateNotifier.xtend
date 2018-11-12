package org.uqbar.project.wollok.ui.contextState

import com.google.inject.Singleton
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.launch.io.IOUtils

@Singleton
class WollokContextStateNotifier {
	var Server server
	var CallHandler callHandler
	
	@Accessors
	var XContextStateListener contextStateListener
	
	@Accessors
	var int listeningPort
	
	def init(XContextStateListener contextStateListener) {
		callHandler = new CallHandler
		callHandler.registerGlobal(XContextStateListener, contextStateListener)

		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort, callHandler)
	}
	
}
