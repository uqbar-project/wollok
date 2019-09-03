package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.Messages

@Accessors
public class WollokTestGlobalContainer {
	var List<WollokTestFileContainer> testFiles = new ArrayList
	var boolean processingManyFiles = false

	def void add(WollokTestFileContainer container) {
		val isAlreadyExists = this.testFiles.findFirst[file|file.mainResource == container.mainResource]
		println(container.mainResource + "isAlreadyExists ? " + isAlreadyExists)
		if (isAlreadyExists === null) {
			testFiles.add(container)
		}
	}

	def String asText() {
		if (processingManyFiles) {
			return Messages.ALL_TEST_IN_PROJECT
		}
		return "Resultado de los test"
	}

	def hasTests() {
		return !testFiles.empty
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.testFiles.forEach[testFile|testFile.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}

/*def testByName(String testName) {
 * 	allTest.findFirst[name == testName]
 * }

 * def allTest() {
 * 	val allTest = new ArrayList
 * 	var unFlattedTests = this.containers.map[container|container.tests]
 * 	unFlattedTests.forEach[tests|allTest.addAll(tests)]
 * 	return allTest
 * }

 * def allTestSize() {
 * 	return this.allTest().size()
 * }

 * def allTestSize((WollokTestResult)=>Boolean predicate) {
 * 	return allTest().filter(predicate).size
 * }

 * def long getMillisecondsElapsed() {
 * 	return containers.fold(0l)[seed, container|container.millisecondsElapsed + seed]
 * }

 * def hasTests() {
 * 	this.containers.size >= 1
 * }

 * def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
 * 	this.containers.forEach[container|container.filterTestByState(shouldShowOnlyFailuresAndErrors)]
 }*/
}
