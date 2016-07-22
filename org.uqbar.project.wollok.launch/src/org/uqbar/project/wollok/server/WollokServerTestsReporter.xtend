package org.uqbar.project.wollok.server

import java.util.List
import org.uqbar.project.wollok.launch.tests.json.WollokJSONTestsReporter
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WTest

class WollokServerTestsReporter extends WollokJSONTestsReporter {
	override testsToRun(WFile file, List<WTest> tests) {
		writer.name("tests").beginArray
	}	
	
	override finished() {
		writer => [
			endArray
			writeSummary
		]		
	}
}