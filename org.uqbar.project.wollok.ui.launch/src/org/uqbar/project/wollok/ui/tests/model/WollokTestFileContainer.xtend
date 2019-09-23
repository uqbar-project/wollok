package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator

@Accessors
class WollokTestFileContainer {
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
		var unFlattedTests = this.containers.map[container|container.allTests]
		unFlattedTests.forEach[tests|allTest.addAll(tests)]
		return allTest
	}

	def allTestSize() {
		return this.allTest().size()
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return allTest().filter(predicate).size
	}	

	def hasTests() {
		this.containers.size >= 1
	}
	
	def getNoEmptyDescribes(){
		val suitesWithName = containers.filter [ container | container.suiteName  !== null] 
		if(suitesWithName.isEmpty){
			return containers.get(0).tests
		}
		return containers.filter [ container | !container.tests.isEmpty ]
		 
	}

	def filterTestByState(boolean shouldShowOnlyFailuresAndErrors) {
		this.containers.forEach[container|container.filterTestByState(shouldShowOnlyFailuresAndErrors)]
	}
	
	def IProject getProject(){
		val path = new Path(mainResource.toFileString)
		ResourcesPlugin.workspace.root.getFileForLocation(path).project
	}
	
	def passed(){
		containers.forall [ passed ]
	}
	
	def running(){
		containers.exists [ running ]
	}
	
	def errored(){
		containers.exists [ errored ]
	}
	
	def failed(){
		containers.exists [ failed ]
	}
	
	def String getInternalImage() {
		if (running) {
			return "icons/wollok-icon-testrun_16.png"
		}
		if (errored) {
			return "icons/wollok-icon-testerr_16.png"
		}
		if (failed) {
			return "icons/wollok-icon-testfail_16.png"
		}
		if (passed) {
			return "icons/wollok-icon-testok_16.png"
		}
		"icons/wollok-icon-test_16.png"		
	}

	def getImage() {
		Activator.getDefault.getImageDescriptor(internalImage)
	}
	
	def fileName() {
		if (mainResource !== null) mainResource.toString else "" 
	}

}
