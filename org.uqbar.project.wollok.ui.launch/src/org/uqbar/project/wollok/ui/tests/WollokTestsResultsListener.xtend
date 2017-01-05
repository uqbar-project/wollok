package org.uqbar.project.wollok.ui.tests

import com.google.inject.Inject
import com.google.inject.Singleton
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.io.IOUtils
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.ui.tests.model.WollokTestResults

@Singleton
class WollokTestsResultsListener{
	val Server server
	val CallHandler callHandler
	
	@Accessors
	val int listeningPort
	
	val WollokTestResults testResults

	@Inject
	new(WollokTestResults testResults) {
		this.testResults = testResults
		
		callHandler = new CallHandler
		callHandler.registerGlobal(WollokRemoteUITestNotifier, testResults)

		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort, callHandler)
	}
	
	def close(){
		server.close()
	}	
}
