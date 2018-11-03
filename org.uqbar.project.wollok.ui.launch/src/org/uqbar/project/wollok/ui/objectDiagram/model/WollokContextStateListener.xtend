package org.uqbar.project.wollok.ui.objectDiagram.model

import com.google.inject.Inject
import com.google.inject.Singleton
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.launch.io.IOUtils
import org.uqbar.project.wollok.ui.objectDiagram.WollokContextState

@Singleton
class WollokContextStateListener {
	val Server server
	val CallHandler callHandler
	val WollokContextState contextStateListener
	
	@Accessors
	val int listeningPort
	
	@Inject
	new(WollokContextState contextStateListener) {
		this.contextStateListener = contextStateListener
		callHandler = new CallHandler
		callHandler.registerGlobal(XContextStateListener, contextStateListener)

		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort, callHandler)
	}
	
}
