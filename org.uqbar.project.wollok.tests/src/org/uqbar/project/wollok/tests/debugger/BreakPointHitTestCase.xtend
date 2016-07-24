package org.uqbar.project.wollok.tests.debugger

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Client
import org.junit.Test
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.out.AsyncXTextInterpreterEventPublisher
import org.uqbar.project.wollok.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.debugger.server.rmi.DebugCommandHandler
import org.uqbar.project.wollok.tests.debugger.util.AbstractXDebuggerImplTestCase
import org.uqbar.project.wollok.tests.debugger.util.DebugEventListenerAsserter
import org.uqbar.project.wollok.tests.debugger.util.TestTextInterpreterEventPublisher

/**
 * Tests a breakpoint being hit by the debugger/interpreter
 * 
 * @author jfernandes
 */
class BreakPointHitTestCase extends AbstractXDebuggerImplTestCase {
	
	@Test
	def void hittingABreakPointShouldRiseAndEvent() {
		'''
			program abc {
				console.println("hello")
				var a = 123
				console.println("a is" + a)
			}
		'''.debugSession [
			setBreakPoint(4)
		   	expect [ 
				on(suspended).thenDo[ resume ]
				on(breakPointHit(4))
					.checkThat [vm |
						val frames = vm.stackFrames
						// 1 stack level
						assertNotNull(frames)
						assertEquals(1, frames.size)
						
						// 1 variable (a = 123)
						assertEquals(1, frames.get(0).variables.size)
						frames.get(0).variables.get(0) => [
							assertEquals("a", variable.name)
							assertEquals("123", value.stringValue)	
						]
					]
					.thenDo [ resume ]
			]
		]		
	}
	
	def void debugSession(CharSequence program, (TestTextInterpreterEventPublisher)=>void debuggerDirector) {
		val programContent = program.toString
		val clientSide = new TestTextInterpreterEventPublisher
		val realDebugger = new XDebuggerImpl => [
//			pause
			eventSender = new AsyncXTextInterpreterEventPublisher(clientSide)
			it.interpreter = interpreter
		]
		
		// Connect To VM To Send commands (like set breakpoint, pause, resume, etc)
			
			// server-side (VM)
			var commandsPort = 7890
			CommandHandlerFactory.createCommandHandler(realDebugger, commandsPort, [])
			
			// client-side (test/ui)
			var commandClient = new Client("localhost", commandsPort, new CallHandler)
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
		interpreterThread.join(5000)
		
		//  TODO: this probably needs to close all threads and sockets it opened !
		//clientSide.close()
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