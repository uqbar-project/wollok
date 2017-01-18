package org.uqbar.project.wollok.typesystem.substitutions

import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

import static extension org.uqbar.project.wollok.utils.XTextExtensions.*

/**
 * A rule for typing a message send return.
 * 
 * @author jfernandes
 */
class MessageSendRule extends TypeRule {
	WMemberFeatureCall call
	WollokType returnType
	
	new(WMemberFeatureCall call) {
		super(call)
		this.call = call
	}
	
	override resolve(SubstitutionBasedTypeSystem system) {
		if (returnType == null) {
			val receiverType = system.typeForExcept(call.memberCallTarget, this)
			if (receiverType == null) {
				println("CANNOT resolve message return type since target was not resolved: (" + call.memberCallTarget.class.simpleName + ") " + NodeModelUtils.findActualNodeFor(call.memberCallTarget).text)
				return false
			}
			val methodType = receiverType.allMessages.findFirst[m| 
				m.name == call.feature
				&& m.parameterTypes.size == call.parameters.size
				// check parameters !
			]
			if (methodType != null)
				this.returnType = methodType.returnType
			true
		}
		else {
			false
		}
	}
	
	override ruleStateLeftPart() { '''t(«call.formattedSourceCode») = «returnType»''' }
	
	override ruleStateRightPart() { "(" + source.lineNumber + ": " + source.formattedSourceCode + ")" }
	
}