package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.Messages

@Accessors
public class WollokTestGlobalContainer {
	var List<WollokTestFileContainer> testFiles = new ArrayList
	var boolean processingManyFiles = false
	long millisecondsElapsed = 0

	def void add(WollokTestFileContainer container) {
		val isAlreadyExists = this.testFiles.findFirst[file|file.mainResource == container.mainResource]
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
		// TODO: seria mejor chequear todos los test children
		return !testFiles.empty
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.testFiles.forEach[testFile|testFile.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}

	def allTest() {
		val allTest = new ArrayList
		this.testFiles.forEach[file|allTest.addAll(file.allTest())]
		return allTest
	}

	def allTest((WollokTestResult)=>Boolean predicate) {
		return allTest().filter(predicate)
	}

	def testByName(String testName) {
		allTest.findFirst[name == testName]
	}
	
	def getProject(){
		this.testFiles.get(0).project
	}

}
