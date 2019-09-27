package org.uqbar.project.wollok.launch.tests

import java.util.List
import java.util.Map
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

/**
 * Does nothing (?)
 * 
 * @author tesonep
 * @author dodain   Adding time elapsed for each test
 */
class DefaultWollokTestsReporter implements WollokTestsReporter {

	Map<WTest,TimeDuration> testTimeElapsed = newHashMap
		
	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		throw assertionError
	}
	
	override reportTestOk(WTest test) {}
	
	override testsToRun(String suiteName, WFile file, List<WTest> tests, boolean reset) {}
	
	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		throw exception
	}
	
	override finished() {
	
	}
	
	override initProcessManyFiles(String folder) {
	}
	
	override endProcessManyFiles() {
	}
	
	override start() {
	}
	
	override testStarted(WTest test) {
		testTimeElapsed.put(test, new TimeDuration(System.currentTimeMillis))
	}
	
	def testFinished(WTest test) {
		testTimeElapsed.get(test).to = System.currentTimeMillis
	}
	
	def getTotalTime(WTest test) {
		testTimeElapsed.get(test).totalTime
	}
	
}

@Accessors
class TimeDuration {
	long from
	long to
	
	new(long from) {
		this.from = from
	}
	
	def totalTime() {
		to - from
	}
}