package org.uqbar.project.wollok.launch

import org.apache.log4j.Logger
import org.uqbar.project.wollok.interpreter.SysoutWollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterStandalone
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.ui.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.ui.debugger.server.rmi.CommandHandlerFactory

import static extension org.uqbar.project.wollok.launch.io.IOUtils.*

/**
 * Main program launcher for the interpreter.
 * Able to run in debug mode in which case it will open ports and publish
 * a service through (lite) RMI to be used from the remote debugger.
 * 
 * @author jfernandes
 */
class WollokLauncher {
	static Logger log = Logger.getLogger(WollokLauncher)
	
	def static void main(String[] args) {
		try {
			log.debug("========================")
			log.debug("    Wollok Launcher")
			log.debug("========================")
			log.debug(" args: " + args.toList)
			
			val interpreter = new WollokInterpreter(new SysoutWollokInterpreterConsole)
			val parameters = new WollokLauncherParameters().parse(args)
			
			
			val debugger = createDebugger(interpreter, parameters)
			interpreter.setDebugger(debugger)
			
			log.debug("Executing program...")
			val fileName = parameters.wollokFiles.get(0)
			
			log.debug("Interpreting: " + fileName)
			interpreter.interpret(WollokInterpreterStandalone.parse(fileName))
			log.debug("Program finished")
			
			System.exit(1)
		} catch (Throwable t) {
			log.error(t.message)
			t.printStackTrace
			System.exit(1)
		}
	}
	
	def static createDebugger(WollokInterpreter interpreter, WollokLauncherParameters parameters) {
		if (parameters.hasDebuggerPorts) {
			createDebuggerOn(interpreter, parameters.requestsPort, parameters.eventsPort)
		}
		else 
			new XDebuggerOff
	}
	
	protected def static createDebuggerOn(WollokInterpreter interpreter, int listenCommandsPort, int sendEventsPort) {
		val debugger = new XDebuggerImpl
		debugger.interpreter = interpreter
		
		log.debug("Opening " + listenCommandsPort)
		createCommandHandler(debugger, listenCommandsPort)
		log.debug(listenCommandsPort + " opened !")
		
		log.debug("Opening " + sendEventsPort)
		val eventSender = new EventSender(openSocket(sendEventsPort))
		debugger.eventSender = eventSender
		eventSender.startDaemon
		log.debug(sendEventsPort + " opened !")
		debugger
	}
	
	def static createCommandHandler(XDebugger debugger, int listenPort) {
		CommandHandlerFactory.createCommandHandler(debugger, listenPort)
	}
	
}