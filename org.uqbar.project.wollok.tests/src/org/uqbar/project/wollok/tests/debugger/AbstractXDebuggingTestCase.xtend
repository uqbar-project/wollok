package org.uqbar.project.wollok.tests.debugger

import java.net.ServerSocket
import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import net.sf.lipermi.net.Server
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.out.AsyncXTextInterpreterEventPublisher
import org.uqbar.project.wollok.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler
import org.uqbar.project.wollok.tests.debugger.util.AbstractXDebuggerImplTestCase
import org.uqbar.project.wollok.tests.debugger.util.DebugEventListenerAsserter
import org.uqbar.project.wollok.tests.debugger.util.TestTextInterpreterEventPublisher

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

/**
 * Abstract base class for all tests for debugging sessions
 * putting breakpoints and stopping, evaluating the state, etc.
 * 
 * @author jfernandes
 */
abstract class AbstractXDebuggingTestCase extends AbstractXDebuggerImplTestCase {
	
	def void debugSession(CharSequence program, (TestTextInterpreterEventPublisher)=>void debuggerDirector) {
		var Server server = null
		var Client commandClient = null
		try {
			val programContent = program.toString
			val clientSide = new TestTextInterpreterEventPublisher
			val realDebugger = new XDebuggerImpl => [
				eventSender = new AsyncXTextInterpreterEventPublisher(clientSide)
				it.interpreter = interpreter
			]
			
			// Connect To VM To Send commands (like set breakpoint, pause, resume, etc)
				
				// server-side (VM)
				var commandsPort = randomBetween(10000, 11000) 
				server = CommandHandlerFactory.createCommandHandler(realDebugger, commandsPort, [])
				
				// client-side (test/ui)
				commandClient = new Client("localhost", commandsPort, new CallHandler)
				val commandHandler = commandClient.getGlobal(DebugCommandHandler) as DebugCommandHandler
			
			interpreter.debugger = realDebugger
			clientSide.commandHandler = commandHandler
	
			// instruct the debugger		
			debuggerDirector.apply(clientSide)
			
			// run !
			val interpreterThread = doInAnotherThread [
				programContent.interpretPropagatingErrors
			]
	
			// now wait !
			clientSide.waitUntilTerminated
	//		interpreterThread.join(5000)
			interpreterThread.join()
			if (interpreterThread.alive) interpreterThread.stop 
			
			clientSide.close()
			(realDebugger.eventSender as AsyncXTextInterpreterEventPublisher).close()
		}
		finally {
			if (commandClient != null)
				commandClient.close
			if (server != null) {
				server.close
				var socketField = Server.declaredFields.findFirst[name == "serverSocket"]
				socketField.accessible = true
				if (socketField != null) {
					val socket = socketField.get(server) as ServerSocket
					socket.close
				}	
			}
		}
	}
	
	// move to factory methods
	
	def static breakPointHit(int expectedLineNumber) {
		new DebugEventListenerAsserter() {
			override breakpointHit(String fileName, int lineNumber, DebugCommandHandler vm) {
				// TODO: take into account filename
				if (lineNumber == expectedLineNumber)
					doIt(vm)
			}
		}
	}
	
	def static started() {
		new DebugEventListenerAsserter {
			override started(DebugCommandHandler vm) { doIt(vm) }
		}
	}
	
	def static suspended() {
		new DebugEventListenerAsserter {
			override suspended(DebugCommandHandler vm) { doIt(vm) }
		}
	}
	
}