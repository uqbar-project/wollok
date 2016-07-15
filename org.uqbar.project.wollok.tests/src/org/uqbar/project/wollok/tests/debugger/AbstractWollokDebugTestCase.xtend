package org.uqbar.project.wollok.tests.debugger

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.debugger.server.out.XTextInterpreterEventPublisher
import org.uqbar.project.wollok.interpreter.stack.XStackFrame
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.uqbar.project.wollok.interpreter.WollokRuntimeException

/**
 * Base class for testing the debugger.
 * Adds methods to evaluate a program step by step, and so on
 * 
 * @author jfernandes
 */
class AbstractWollokDebugTestCase extends AbstractWollokInterpreterTestCase {
	// couldn't reuse the one from xtext because it is hardcoded
	static val SYNTHETIC_FILE_PREFFIX = "__synthetic"
	
	def debugSteppingInto(CharSequence programAsString, (DebugAsserter)=>Object assertion) {
		val program = programAsString.toString()
		val steps = debugSteppingInto(program)
		
		val asserter = new DebugAsserter
		asserter.program = program
		assertion.apply(asserter)
		
//		assertEquals("Number of steps executed was different than expected ! ", asserter.expectedSteps.size, steps.size)
		
		var i = 0
		for (s : steps) {
			// REVIEW: we are ignoring steps that are in another files 
			// like wollok/lang.wlk
			// Eventually the test infrastructure needs to add support for this
			if (s.currentLocation.fileURI.contains(SYNTHETIC_FILE_PREFFIX)) {
				println("Asserting " + s.currentLocation.fileURI)
				if (i >= asserter.expectedSteps.size) {
					fail("Found extra step not in expectation: " + s.code(program))
				}
				assertEquals("Wrong step number " + i, asserter.expectedSteps.get(i), s.code(program))
				i++
			}
		}
		// there are more steps because of the methods you call objects outside of the test
//		assertEquals("Number of steps executed was different than expected ! ", asserter.expectedSteps.size, steps.size)
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
			println("Evaluating "+ lastStackElement + " => " + code.replaceAll('\n', '¶'))

			realDebugger.stepInto()	
		} while (!clientSide.isTerminated);
		
		println("Steps " + steps.map[System.identityHashCode(it)].join(', '))
		steps
	}
	
	def code(XStackFrame element, String program) {
		// currently cannot resolve sourcecode from code outside of the test code.
		if (!element.currentLocation.fileURI.startsWith(SYNTHETIC_FILE_PREFFIX))
			return element.currentLocation.toString
		
		val offset = element.currentLocation.offset
		val length = element.currentLocation.length
		
		if (offset >= program.length)
			throw new WollokRuntimeException("Stack element with source out of program bounds (offset=" + offset + ", program length=" + program.length + " : " + element.currentLocation)
		if (offset + length > program.length)
			throw new WollokRuntimeException("Stack element with source out of program bounds (endOffset=" + (offset + length) + ", program length=" + program.length + " : " + element.currentLocation)
		// the last stack is up to the size (don't know why :S)	
		program.substring(offset, Math.min(program.length, offset + length))
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