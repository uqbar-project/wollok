package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import java.net.URLDecoder
import java.rmi.ConnectException
import java.util.List
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.out.AsyncXTextInterpreterEventPublisher
import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.uqbar.project.wollok.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokRuntimeException
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.repl.AnsiColoredReplOutputFormatter
import org.uqbar.project.wollok.launch.repl.RegularReplOutputFormatter
import org.uqbar.project.wollok.launch.repl.WollokRepl
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Main program launcher for the interpreter.
 * Able to run in debug mode in which case it will open ports and publish
 * a service through (lite) RMI to be used from the remote debugger.
 * 
 * @author jfernandes
 */
class WollokLauncher extends WollokChecker {

	def static void main(String[] args) {
		new WollokLauncher().doMain(args)
	}
	
	override doSomething(List<String> fileNames, Injector injector, WollokLauncherParameters parameters) {
		try {
			val interpreter = injector.getInstance(WollokInterpreter)
			val debugger = createDebugger(interpreter, parameters)
			interpreter.setDebugger(debugger)
			val filesToParse = fileNames.map [ wollokFile |
				new File(wollokFile)
			]
			interpreter.interpret(filesToParse.parse)
			System.exit(0)
		} catch (Exception e) {
			System.exit(-1)
		}
		
	}

	override doSomething(WFile parsed, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		try {
			val interpreter = injector.getInstance(WollokInterpreter)
			val debugger = createDebugger(interpreter, parameters)
			interpreter.setDebugger(debugger)

			log.debug("Interpreting: " + mainFile.absolutePath)
			interpreter.interpret(parsed)
	
			if (parameters.hasRepl) {
				val formatter = if (parameters.noAnsiFormat) new RegularReplOutputFormatter else new AnsiColoredReplOutputFormatter 
				new WollokRepl(this, injector, interpreter, mainFile, parsed, formatter).startRepl
			}
			System.exit(0)
		}
		catch (Exception e) {
			System.exit(-1)
		}
	}

	def createDebugger(WollokInterpreter interpreter, WollokLauncherParameters parameters) {
		if (parameters.hasDebuggerPorts) {
			createDebuggerOn(interpreter, parameters.requestsPort, parameters.eventsPort)
		} else
			new XDebuggerOff
	}

	protected def createDebuggerOn(WollokInterpreter interpreter, int listenCommandsPort, int sendEventsPort) {
		val debugger = new XDebuggerImpl
		debugger.interpreter = interpreter

		log.debug("Listening for incoming connection " + listenCommandsPort)
		registerCommandHandler(debugger, listenCommandsPort)
		log.debug(listenCommandsPort + " opened !")
		
		

		log.debug("Connecting to client " + sendEventsPort)
		val client = connectToClient(sendEventsPort)
		debugger.eventSender = client
		
		debugger
	}
	
	def XTextInterpreterEventPublisher connectToClient(int port) {
		var retries = 1
		do {
			try {
				Thread.sleep(1000)
				log.debug("[VM] Connecting to Client on port " + port + " (attempt " + retries + "/3) ...")
				val client = new Client("localhost", port, new CallHandler)
				log.debug("[VM] Connected !")
				val remoteObject = client.getGlobal(XTextInterpreterEventPublisher) as XTextInterpreterEventPublisher
				// client events are async, don't want to block the interpreter
				return new AsyncXTextInterpreterEventPublisher(remoteObject)
			}
			catch (ConnectException e) {
				e.printStackTrace
				retries++
			}
		} while (retries < 4)
		
		throw new WollokRuntimeException("Could NOT connect to debugger client !")
	}
	
	Object debuggerStartLock = new Object()

	def void registerCommandHandler(XDebugger debugger, int listenPort) {
		log.debug("[VM] Listening for clients on port " + listenPort)
		CommandHandlerFactory.createCommandHandler(debugger, listenPort, [
			synchronized(debuggerStartLock) {
				debuggerStartLock.notify
			}
		])
		synchronized(debuggerStartLock) {
			log.debug("Waiting for client call to start up")
			debuggerStartLock.wait
		}
		log.debug("Client connected now proceeding with execution")
	}

}
