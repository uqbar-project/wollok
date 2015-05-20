package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.repl.WollokRepl
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.launch.io.IOUtils.*

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

	override doSomething(WFile parsed, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		log.debug("Interpreting: " + mainFile.absolutePath)
		val interpreter = injector.getInstance(WollokInterpreter)
		val debugger = createDebugger(interpreter, parameters)
		interpreter.setDebugger(debugger)
		interpreter.interpret(parsed)

		if (parameters.hasRepl) {
			new WollokRepl(this, injector, interpreter, mainFile).startRepl
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

	def createCommandHandler(XDebugger debugger, int listenPort) {
		CommandHandlerFactory.createCommandHandler(debugger, listenPort)
	}

}
