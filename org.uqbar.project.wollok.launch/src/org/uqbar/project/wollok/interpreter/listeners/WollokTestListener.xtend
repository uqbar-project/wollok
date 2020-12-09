package org.uqbar.project.wollok.interpreter.listeners

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.interpreter.api.XInterpreterListener
import org.uqbar.project.wollok.sdk.WollokSDK
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

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
	
	def dispatch static hasMessageToAssert(EObject e) { false }
	def dispatch static hasMessageToAssert(WMemberFeatureCall call) {
		call.memberCallTarget?.astNode.text.trim.equals(WollokSDK.ASSERT_WKO)
	}
	
	def hasNoAssertions() {
		messagesToAssert === 0
	}
	
}
