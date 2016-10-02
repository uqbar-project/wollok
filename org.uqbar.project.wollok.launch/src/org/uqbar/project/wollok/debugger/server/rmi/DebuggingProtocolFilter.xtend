package org.uqbar.project.wollok.debugger.server.rmi

import net.sf.lipermi.call.IRemoteMessage
import net.sf.lipermi.call.RemoteCall
import net.sf.lipermi.handler.filter.DefaultFilter
import net.sf.lipermi.call.RemoteReturn
import java.util.Map

/**
 * an IProtocolFilter implementation to debug the RMI communication
 * 
 * @author jfernandes
 */
class DebuggingProtocolFilter extends DefaultFilter {
	var Map<Long,Long> timestamps = newHashMap() // callId, startTime

	override readObject(Object obj) {
		if (obj instanceof RemoteCall)
			timestamps.put(obj.callId, System.nanoTime)
		println("[VM] reading object " + obj.description)
		super.readObject(obj)
	}

	override prepareWrite(IRemoteMessage message) {
		var took = 0l
		if (message instanceof RemoteReturn)
			took = System.nanoTime - timestamps.get(message.callId)
		println("[VM] preparing write " + message.description + " TOOK " + took + " nanosecs") 
		super.prepareWrite(message)
	}

	def dispatch String description(RemoteCall it) {
		'''RemoteCall(remoteInstance = «remoteInstance», callId = «callId» methodId = «methodId» args = «args»)'''
	}
	
	def dispatch String description(RemoteReturn r) {
		'''RemoteReturn(callId = «r.callId», ret = «r.ret», throwing = «r.throwing»)'''
	}
	
	def dispatch String description(Object it) { toString }

}
