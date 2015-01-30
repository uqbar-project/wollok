package org.uqbar.project.wollok.launch.io

import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.io.PrintWriter
import java.net.InetAddress
import java.net.ServerSocket
import java.net.Socket
import org.uqbar.project.wollok.launch.WollokLauncherException

/**
 * 
 * @author jfernandes
 */
class IOUtils {
	
	// factory methods
	def static createClientSocket(int port) { 
		try
			new Socket(InetAddress.getByName(null), port)
		catch (IOException e)
			throw new WollokLauncherException("Could not connect to port [" + port + "]", e)
		catch (RuntimeException e)
			throw new WollokLauncherException("Could not connect to port [" + port + "]", e)
	}
	
	def static writter(Socket socket) { 
		try 
			new PrintWriter(socket.outputStream)
		catch (IOException e)
			throw new WollokLauncherException("Could not open stream to write to", e)
		catch (RuntimeException e)
			throw new WollokLauncherException("Could not open stream to write to", e) 
	}
	
	def static reader(Socket socket) { 
		try 
			new BufferedReader(new InputStreamReader(socket.inputStream))
		catch (IOException e)
			throw new WollokLauncherException("Could not open stream to read from socket", e)
	}
	
	def static createSocket(int port) {
		try
			new ServerSocket(port, 0, InetAddress.getByName(null))
		catch (IOException e)
			throw new WollokLauncherException("Could not listen on port [" + port + "]", e)
	}
	
	def static accept(ServerSocket server) {
		try
			server.accept
		catch (IOException e) {
			throw new WollokLauncherException("Could not accept incoming connection!", e)
		}
	}
	
	def static openSocket(int port) {
		val client = createSocket(port).accept
		val in = createInputStream(client)
  		var out = new PrintWriter(client.outputStream, true)
  		new CommunicationChannel(in, out)
	}
	
	protected def static createInputStream(Socket client) {
		try
		   	new BufferedReader(new InputStreamReader(client.inputStream))
		catch (IOException e) {
			throw new WollokLauncherException("Could not open streams for reading connection!", e)
		}
	}
	
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