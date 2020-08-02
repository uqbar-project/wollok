package org.uqbar.project.wollok.tests.interpreter

import org.junit.ComparisonFailure
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.interpreter.nativeobj.WollokJavaConversions.wollokToJava

class WollokComparisonFailure extends ComparisonFailure {
	val String originalMessage
	val WollokObject wollokException

	new(WollokProgramExceptionWrapper e) {
		super(e.wollokMessage, e.wollokException.call("expected").wollokToJava(String) as String,
			e.wollokException.call("actual").wollokToJava(String) as String)
		wollokException = e.wollokException
		originalMessage = e.wollokMessage
		this.fillInStackTrace
	}

	override getMessage() {
		return originalMessage
	}

	override synchronized fillInStackTrace() {
		if(wollokException === null)
			return this
		
		val elements = wollokException.convertStackTrace.map[asStackTraceElement]
		stackTrace = elements.toArray(<StackTraceElement>newArrayOfSize(0))
		this
	}


}
