package org.uqbar.project.wollok.launch.tests.json

import com.google.gson.Gson
import com.google.gson.stream.JsonWriter
import java.io.PrintWriter
import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.launch.Wollok
import org.uqbar.project.wollok.launch.tests.WollokTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.utils.XtendExtensions.*
import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import org.uqbar.project.wollok.interpreter.core.WollokObject

/**
 * A test reporter that prints to console in JSON format.
 * Used by mumuki, for example.
 * 
 * @author jfernandes
 * @author npasserini
 */
// TODO: it could be rendering the elapsed time for each test
// TODO: This should be using our JSonWriter to simplify code and unify some conventions (e.g. stack trace formats).
class WollokJSONTestsReporter implements WollokTestsReporter {
	var testPassed = 0
	var testFailures = 0
	var testErrors = 0

	var JsonWriter _writer

	override testsToRun(String suiteName, WFile file, List<WTest> tests) {
		writer.beginObject => [
			name("version").value(Wollok.VERSION)
			if (!suiteName.empty) name("suite").value(suiteName)
			name("tests").beginArray
		]
	}

	override finished(long millisecondsElapsed) {
		writer => [
			endArray
			writeSummary
			close
		]
	}

	def writeSummary(JsonWriter it) {
		name("summary").beginObject => [
			name("passed").value(testPassed)
			name("failures").value(testFailures)
			name("errors").value(testErrors)
		]
		endObject
	}

	override testStart(WTest test) {}

	def static operator_doubleArrow(JsonWriter writer, Pair<String, Object> pair) {
		pair.value.interpret(writer.name(pair.key))
	}

	def static dispatch interpret(String it, JsonWriter w) { w.value(it) }

	def static dispatch interpret(Number it, JsonWriter w) { w.value(it) }

	def static dispatch interpret((JsonWriter)=>JsonWriter it, JsonWriter w) {
		apply(w.beginObject).endObject
	}

	def static operator_doubleGreaterThan(WollokJSONTestsReporter it, (JsonWriter)=>JsonWriter closure) {
		closure.apply(writer.beginObject).endObject
	}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {
		writer => [
			beginObject
				name("name").value(test.name)
				name("state").value("failed")
				name("error").beginObject
					name("message").value(assertionError.message)
					name("file").value(resource.trimFragment.toString)
					name("lineNumber").value(lineNumber)
					name("stackTrace").beginArray
						assertionError.wollokStackTrace.forEach [ element |
							beginObject
								name("contextDescription").value(element.call("contextDescription").asString)
								name("location").value(element.call("location").asString)
							endObject
						]
					endArray
				endObject
			endObject
		]
		testFailures++
	}
	
	override reportTestOk(WTest test) {
		writer => [
			beginObject 
				name("name").value(test.name) 
				name("state").value("passed") 
			endObject
		]
		testPassed++
	}

	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) {
		writer => [
			beginObject
				name("name").value(test.name)
				name("state").value("error")
				name("error").beginObject
					name("message").value(exception.theWollokMessage)
					// name("file").value(resource.trimFragment.toString)
					name("lineNumber").value(lineNumber)
					name("stackTrace").value(exception.wollokStackTraceAsString)
				endObject
			endObject
		]
		testErrors++
	}

	// ************************************************************************
	// ** Util
	// ************************************************************************

	def dispatch String getTheWollokMessage(Exception exception) { exception.message }

	def dispatch String getTheWollokMessage(WollokProgramExceptionWrapper exception) { exception.wollokMessage }

	def dispatch String getWollokStackTraceAsString(Exception exception) { exception.stackTraceAsString }

	def dispatch String getWollokStackTraceAsString(WollokProgramExceptionWrapper exception) {
		exception.wollokStackTrace
	}

	def getWollokStackTrace(AssertionException exception) {
		// This is almost repeated in WollokServer and should be reviewed.
		(exception.wollokException
			.call("getStackTrace")
			.asList.wrapped as List<WollokObject>)
			.allButFirst
	}

	// ************************************************************************
	// ** Accessors
	// ************************************************************************

	def getWriter() {
		if (_writer === null) {
			_writer = (new Gson).newJsonWriter(new PrintWriter(System.out))
		}
		_writer
	}
	
	def setWriter(JsonWriter writer) {
		_writer = writer
	}

	override initProcessManyFiles(String folder) {
	}
	
	override endProcessManyFiles() {
	}
	
}
