package org.uqbar.project.wollok.launch.tests

import java.util.List
import org.eclipse.emf.common.util.URI
import org.uqbar.project.wollok.launch.Wollok
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest
import wollok.lib.AssertionException

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.* import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

/**
 * 
 * @author jfernandes
 */
class WollokJSONTestsReporter implements WollokTestsReporter {
	var testPassed = 0
	var testErrors = 0
	var first = true
	
	override testsToRun(WFile file, List<WTest> tests) { println('''
{
	"version" : "«Wollok.VERSION»",
	"tests" : [''')}
	
	override finished() {println(
'''		]
}''')}
	
	override testStart(WTest test) {}

	override reportTestAssertError(WTest test, AssertionException assertionError, int lineNumber, URI resource) {println(
'''
	 {
		"name" : "«test.name»",
		"state" : "failed"
		"error" : {
			"message" : "«assertionError.message»",
			"file" : "«resource.trimFragment»",
			"lineNumber" : "«lineNumber»",
			"stackTrace" : "«assertionError.stackTraceAsString»""
		}
	}''')}
	
	override reportTestOk(WTest test) { println(
'''
    {
    "name" : "«test.name»",
        "state" : "passed"
    }''')}
	
	override reportTestError(WTest test, Exception exception, int lineNumber, URI resource) { println(
'''
	{
		"name" : "«test.name»",
		"state" : "error"
		"error" : {
			"message" : "«exception.theWollokMessage»",
			"stacktrace" : "«exception.wollokStackTraceAsString»"
			"file" : "«resource.trimFragment»",
			"lineNumber" : "«lineNumber»"
		}
	}''')}
	
	def dispatch getTheWollokMessage(Exception exception) { exception.message }
	def dispatch getTheWollokMessage(WollokProgramExceptionWrapper exception) { exception.wollokMessage }
	
	def dispatch getWollokStackTraceAsString(Exception exception) { exception.stackTraceAsString }
	def dispatch getWollokStackTraceAsString(WollokProgramExceptionWrapper exception) { exception.wollokStackTrace }
	
}