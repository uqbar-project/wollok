package org.uqbar.project.wollok.launch.io

import java.io.IOException
import java.net.ServerSocket

/**
 * 
 * @author jfernandes
 */
class IOUtils {
	
	// THREADING
	
	def static start(Runnable runnable) { new Thread(runnable).start }
	/** 
	 * Starts a thread in "daemon-mode". So VM will shut it down if main thread has finished. 
	 * It Won't keep the process running just for this thread.
	 */
	def static startDaemon(Runnable runnable) { 
		new Thread(runnable) => [
			daemon = true
			start 
		]
	}
	
	/**
	 * Returns a free port number on localhost, or -1 if unable to find a free port.
	 */
	def static int findFreePort() {
		var ServerSocket socket = null
		try {
			socket = new ServerSocket(0)
			socket.localPort
		} catch (IOException e)
			-1
		finally {
			if (socket != null) {
				try
					socket.close
				catch (IOException e) {
				}
			}
		}		
	}
	
}