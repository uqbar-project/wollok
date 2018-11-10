package org.uqbar.project.wollok.ui.contextState

import com.google.inject.Inject
import com.google.inject.Singleton
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.contextState.server.XContextStateListener
import org.uqbar.project.wollok.launch.io.IOUtils
import org.uqbar.project.wollok.ui.diagrams.dynamic.DynamicDiagramView

@Singleton
class WollokContextStateNotifier {
	val Server server
	val CallHandler callHandler
	
	@Accessors
	val DynamicDiagramView contextStateListener
	
	@Accessors
	val int listeningPort
	
	@Inject
	new(DynamicDiagramView contextStateListener) {
		this.contextStateListener = contextStateListener
		callHandler = new CallHandler
		callHandler.registerGlobal(XContextStateListener, contextStateListener)

		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort, callHandler)
	}
	
}
