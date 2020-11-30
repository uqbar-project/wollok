package org.uqbar.project.wollok.launch.tests.json

import java.io.PrintWriter
import java.util.List
import org.eclipse.xtext.validation.Issue
import org.uqbar.project.wollok.Wollok
import org.uqbar.project.wollok.launch.WollokLauncherIssueHandler
import org.uqbar.project.wollok.server.JSonWriter

import static extension org.uqbar.project.wollok.server.JSonWriter.*

/**
 * JSON handler
 * 
 * @author jfernandes
 * @author npasserini
 */
class WollokLauncherIssueHandlerJSON implements WollokLauncherIssueHandler {
	val List<Issue> issues = newArrayList
	
	override handleIssue(Issue issue) { issues += issue }
	
	override finished() {
		new PrintWriter(System.out).writeJson [
			object [
				value("version", Wollok.VERSION)
				array("checks", issues) [ it, issue | renderIssue(issue) ]		
			]
		]
	}
	
	def renderIssue(JSonWriter it, Issue i) {
		object [
			value("severity", i.severity.name)
			value("code", i.code)
			value("message", i.message)
			value("lineNumber", i.lineNumber)
			value("offset", i.offset)
			value("length", i.length)
			value("uri", i.uriToProblem.toFileString)
			value("syntaxError", i.syntaxError)
			if (i.data !== null) { array("data", i.data) }
		]
	}	
}