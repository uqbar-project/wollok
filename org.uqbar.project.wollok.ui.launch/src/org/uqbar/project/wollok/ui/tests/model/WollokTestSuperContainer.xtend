package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.Messages

@Accessors
class WollokTestSuperContainer {
	var List<WollokTestContainer> containers = new ArrayList
	var URI mainResource
	var boolean processingManyFiles = false

	def void add(WollokTestContainer container) {
		containers.add(container)
	}

	def String asText() {
		return mainResource.lastSegment
	}

	def testByName(String testName) {
		allTest.findFirst[name == testName]
	}

	def allTest() {
		val allTest = new ArrayList
		var unFlattedTests = this.containers.map[container|container.tests]
		unFlattedTests.forEach[tests|allTest.addAll(tests)]
		return allTest
	}

	def allTestSize() {
		return this.allTest().size()
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return allTest().filter(predicate).size
	}

	def long getMillisecondsElapsed() {
		return containers.fold(0l)[seed, container|container.millisecondsElapsed + seed]
	}

	def hasTests() {
		this.containers.size >= 1
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.containers.forEach[container|container.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}

}
