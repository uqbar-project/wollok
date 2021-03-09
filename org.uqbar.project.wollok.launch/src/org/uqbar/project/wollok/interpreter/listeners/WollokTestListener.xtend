package org.uqbar.project.wollok.interpreter.listeners

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.uqbar.project.wollok.sdk.WollokSDK
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

class WollokTestListener implements XInterpreterListener {
	int messagesToAssert = 0
 		
	override started() {
	}
	
	override terminated() {
	}
	
	override aboutToEvaluate(EObject element) {
	}
	
	override evaluated(EObject element) {
		if (element.hasMessageToAssert) messagesToAssert++
	}
	
	def dispatch static boolean hasMessageToAssert(EObject e) { false }

	def dispatch static boolean hasMessageToAssert(WMemberFeatureCall call) {
		call.memberCallTarget.receiver.equals(WollokSDK.ASSERT_WKO)
	}

//	def dispatch static boolean hasMessageToAssert(WCatch c) {
//		c.expression.hasMessageToAssert
//	}

	def dispatch static boolean hasMessageToAssert(WBlockExpression block) {
		block.expressions.exists [ hasMessageToAssert ]
	}
	
	def hasNoAssertions() {
		messagesToAssert === 0
	}
	
}
