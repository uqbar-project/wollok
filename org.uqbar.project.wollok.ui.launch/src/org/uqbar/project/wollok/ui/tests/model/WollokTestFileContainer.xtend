package org.uqbar.project.wollok.ui.tests.model

import java.util.ArrayList
import java.util.List
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.ui.launch.Activator
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

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
		allTests.findFirst[name == testName]
	}

	def getAllTests() {
		this.containers.flatMap [ allTests ]
	}

	def allTestSize() {
		return this.allTests.size()
	}

	def allTestSize((WollokTestResult)=>Boolean predicate) {
		return allTests.filter(predicate).size
	}	

	def hasTests() {
		this.containers.size >= 1
	}
	
	def getNoEmptyDescribes(){
		val suitesWithName = containers.filter [ suiteName !== null ] 
		if (suitesWithName.isEmpty) {
			return containers.head.tests
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
			return "icons/wtest_run" + themeSuffix + ".png"
		}
		if (errored) {
			return "icons/wtest_error" + themeSuffix + ".png"
		}
		if (failed) {
			return "icons/wtest_fail" + themeSuffix + ".png"
		}
		if (passed) {
			return "icons/wtest_ok" + themeSuffix + ".png"
		}
		"icons/wtest.png"
	}

	def getImage() {
		Activator.getDefault.getImageDescriptor(internalImage)
	}
	
	def fileName() {
		if (mainResource !== null) mainResource.toString else "" 
	}

	override toString() {
		"[" + allTests.map [ name ].join(",") + "]" 
	}

}
