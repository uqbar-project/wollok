package org.uqbar.project.wollok.ui.debugger.server

import java.io.IOException
import org.apache.log4j.Logger
import org.uqbar.project.wollok.launch.io.CommunicationChannel

/**
 * Abstract base class for an object that runs in a dedicated thread
 * in order to handle a CommunicationChannel.
 * 
 * It executes a loop an reads from the input.
 * It also provides methods for writing into the channel.
 * 
 * It also handles termination.
 * 
 * @author jfernandes
 */
abstract class AbstractCommunicationHandlerRunnable implements Runnable {
	protected Logger log = Logger.getLogger(AbstractCommunicationHandlerRunnable)
	@Property CommunicationChannel channel
	@Property boolean terminate = false
	
	new(CommunicationChannel channel) {
		this.channel = channel
	}
	
	override run() {
		while (!terminate) {
	      try {
	        var line = channel.in.readLine
	        log.debug(">>> INCOMING: " + line)
			handleIncomingSafely(line)
	      }
	      catch (IOException e) {
	        log.error("Read failed")
	        System.exit(-1)
	      }
	    }
	}
	
	def handleIncomingSafely(String line) {
		try {
			incoming(line)
		}
		catch (Exception e) {
			log.error("Debugger error handling command: " + line, e)
			System.exit(-1)
		}
	}
	
	def void incoming(String line)
	
	def void sendAck() {
		log.debug("<<< ACK")
		channel.out.println("OK")
	}
	
	def sendEvent(String event, Object... args) {
		var message = event
		for (a : args)
			message += " " + a
		log.debug("<<< OUTGOING: " + message)
		channel.out.println(message)
		channel.out.flush
	}
	
	def stop() {
		channel.close
		terminate = true
	}

}