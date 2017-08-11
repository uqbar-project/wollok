package org.uqbar.project.wollok.linking

import com.google.inject.Singleton
import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.diagnostics.DiagnosticMessage
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.linking.impl.IllegalNodeException
import org.eclipse.xtext.linking.impl.LinkingDiagnosticMessageProvider

import static org.uqbar.project.wollok.Messages.*

import static extension org.uqbar.project.wollok.WollokModelUtils.*

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
		
		val msg = LINKING_COULD_NOT_RESOLVE_REFERENCE + referenceType.humanReadableModelTypeName + " '" + linkText + "'."
		new DiagnosticMessage(msg, Severity.ERROR, Diagnostic.LINKING_DIAGNOSTIC)
	}
	
}