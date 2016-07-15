package org.uqbar.project.wollok.tests.debugger

import java.util.List
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
	
	def debugSteppingInto(CharSequence programAsString, (DebugAsserter)=>Object assertion) {
		val program = programAsString.toString()
		val steps = debugSteppingInto(program)
		
		val asserter = new DebugAsserter
		asserter.program = program
		assertion.apply(asserter)
		
		assertEquals("Number of steps executed was different than expected !", 6, asserter.expectedSteps.size)
		
		var i = 0
		for (s : steps) {
			assertEquals(asserter.expectedSteps.get(i), s.code(program))
			i++
		}
	}
	
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
		var List<XStackFrame> steps = newArrayList
		var XStackFrame lastStackElement = null
		do {
			Thread.sleep(100)
			
			lastStackElement = realDebugger.stack.lastElement
			steps += lastStackElement.clone
			
			val code = lastStackElement.code(programContent)
			
//			println("Evaluating "+ lastStackElement + " => " + code.replaceAll('\n', '¶'))
			realDebugger.stepInto()	
		} while (!clientSide.isTerminated);
		
		println("Steps " + steps.map[System.identityHashCode(it)].join(', '))
		steps
	}
	
	def code(XStackFrame element, String program) {
		val offset = element.currentLocation.offset
		val length = element.currentLocation.length
		program.substring(offset, offset + length)
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