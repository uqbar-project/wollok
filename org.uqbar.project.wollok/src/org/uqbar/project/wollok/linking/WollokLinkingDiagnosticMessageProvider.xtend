package org.uqbar.project.wollok.linking

import com.google.inject.Singleton
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.linking.impl.IllegalNodeException
import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider
import org.uqbar.project.wollok.wollokDsl.WAssignment

import static org.uqbar.project.wollok.Messages.*

import static extension org.uqbar.project.wollok.errorHandling.HumanReadableUtils.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Overrides the default implementation to i18nize messages
 * for linking errors
 * 
 * @author jfernandes
 */
 @Singleton
class WollokLinkingDiagnosticMessageProvider extends LinkingDiagnosticMessageProvider {
	
	override getUnresolvedProxyMessage(ILinkingDiagnosticContext context) {
		val referenceType = context.reference.EReferenceType
		var linkText = try context.linkText catch (IllegalNodeException e) e.node.text

		var msg = ""
		val constructorCall = context.context.declaringConstructorCall
		if (constructorCall !== null) {
			val namedParameters = constructorCall.arguments.filter [ it instanceof WAssignment ].size
			val arguments = constructorCall.arguments.filter [ !(it instanceof WAssignment) ].size
			if (arguments > 0 && namedParameters > 0) {
				msg = SYNTAX_DIAGNOSIS_CONSTRUCTOR_WITH_BOTH_INITIALIZERS_AND_VALUES	
			}
		}
		if (msg.equals("")) {
			val modelTypeName = referenceType.modelTypeName
			val separator = if (modelTypeName === "") "" else " "
			msg = LINKING_COULD_NOT_RESOLVE_REFERENCE + modelTypeName + separator + "'" + linkText + "'."
		}
		new DiagnosticMessage(msg, Severity.ERROR, Diagnostic.LINKING_DIAGNOSTIC)
	}
	
}