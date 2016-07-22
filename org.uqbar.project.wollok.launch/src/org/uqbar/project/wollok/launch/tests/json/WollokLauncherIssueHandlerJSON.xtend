package org.uqbar.project.wollok.launch.tests.json

import com.google.gson.Gson
import com.google.gson.stream.JsonWriter
import java.io.PrintWriter
import java.util.List
import org.eclipse.xtext.validation.Issue
import org.uqbar.project.wollok.launch.Wollok
import org.uqbar.project.wollok.launch.WollokLauncherIssueHandler

/**
 * JSON handler
 * 
 * @author jfernandes
 */
class WollokLauncherIssueHandlerJSON implements WollokLauncherIssueHandler {
	val List<Issue> issues = newArrayList
	
	override handleIssue(Issue issue) { issues += issue }
	
	override finished() {
		new Gson().newJsonWriter(new PrintWriter(System.out)) => [
			obj [
				with("version", Wollok.VERSION)
				name("checks").beginArray
					renderIssues				
				endArray
			]
			close
		]
	}
	
	def renderIssues(JsonWriter it) {
		issues.forEach[issue | renderIssue(issue)]
	}
	
	def renderIssue(JsonWriter it, Issue i) {
		obj [
			with("severity", i.severity.name)
			with("code", i.code)
			with("message", i.message)
			with("lineNumber", i.lineNumber)
			with("offset", i.offset)
			with("length", i.length)
			with("uri", i.uriToProblem.toFileString)
			with("syntaxError", i.syntaxError)
			array("data", i.data)
		]
	}
	
	// *****************************
	// ** JSON DSL utils 
	// *****************************
	
	def obj(JsonWriter it, ()=>Object closure) {
		beginObject
			closure.apply
		endObject
	} 
	
	def with(JsonWriter it, String name, String value) { name(name).value(value) }
	def with(JsonWriter it, String name, int value) { name(name).value(value) }
	def with(JsonWriter it, String name, boolean value) { name(name).value(value) }
	
	def array(JsonWriter it, String name, String[] value) { 
		name(name)
		beginArray
			if (value != null) value.forEach[v| value(v)]
		endArray
	}
	
}