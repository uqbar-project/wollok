package org.uqbar.project.wollok.tests.debugger

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * Base class for testing the debugger.
 * Adds methods to evaluate a program step by step, and so on
 * 
 * @author jfernandes
 */
class AbstractWollokDebugTestCase extends AbstractWollokInterpreterTestCase {
	
	def debugSteppingInto(CharSequence program) {
		val programContent = program.toString
		val clientSide = new TestTextInterpreterEventPublisher
		val realDebugger = new XDebuggerImpl() => [
			// starts paused
			pause
			eventSender = clientSide
			it.interpreter = interpreter
		]
		interpreter.debugger = realDebugger
		
		val thread = doInAnotherThread [
			programContent.interpretPropagatingErrors
		]
		
		clientSide.waitUntilStarted

		val steps = clientSide.runSteppingInto(realDebugger, programContent)
		
		thread.join(5000)
		return steps
	}
	
	// utils
	
	private def runSteppingInto(TestTextInterpreterEventPublisher clientSide, XDebuggerImpl realDebugger, String programContent) {
		var steps = newArrayList
		var XStackFrame lastStackElement = null
		while (!clientSide.isTerminated) {
			Thread.sleep(100)
			
			lastStackElement = realDebugger.stack.last
			steps.add(lastStackElement)
			
			val offset = lastStackElement.currentLocation.offset
			val length = lastStackElement.currentLocation.length
			val content = programContent.substring(offset, offset + length) 

			println("Evaluating "+ realDebugger.stack.last + " => " + content.replaceAll('\n', '¶'))
			realDebugger.stepInto()	
		}
		steps
	}
	
	private def doInAnotherThread(Runnable a) {
		val thread = new Thread([
			try {
				a.run
			}	
			catch (Throwable t) {
				t.printStackTrace
			}
		])
		thread.start
		thread
	}
	
	private def waitUntilStarted(TestTextInterpreterEventPublisher clientSide) {
		while (!clientSide.isStarted) Thread.sleep(100)
	}
	
}

@Accessors
class TestTextInterpreterEventPublisher implements XTextInterpreterEventPublisher {
	var boolean started = false
	var boolean terminated = false
	
	override started() { started = true }
	override terminated() { terminated = true	}
	
	override suspendStep() {}
	override resumeStep() { }
	override breakpointHit(String fileName, int lineNumber) { }
	
}