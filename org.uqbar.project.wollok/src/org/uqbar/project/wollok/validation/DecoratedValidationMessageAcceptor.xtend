package org.uqbar.project.wollok.validation

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.ValidationMessageAcceptor

/**
 * Decorates a validation message to default error codes.
 * 
 * @author jfernandes
 */
class DecoratedValidationMessageAcceptor implements ValidationMessageAcceptor {
	ValidationMessageAcceptor decoratee
	String defaultCode
	
	new(ValidationMessageAcceptor decoratee, String defaultCode) {
		this.decoratee = decoratee
		this.defaultCode = defaultCode
	}

	def checkCode(String code) {
		if (code === null)  defaultCode else code
	}
	
	override acceptError(String message, EObject object, EStructuralFeature feature, int index, String code, String... issueData) {
		decoratee.acceptError(message, object, feature, index, checkCode(code), issueData)
	}
	
	override acceptError(String message, EObject object, int offset, int length, String code, String... issueData) {
		decoratee.acceptError(message, object, offset, length, checkCode(code), issueData)
	}
	
	override acceptInfo(String message, EObject object, EStructuralFeature feature, int index, String code, String... issueData) {
		decoratee.acceptInfo(message, object, feature, index, checkCode(code), issueData)
	}
	
	override acceptInfo(String message, EObject object, int offset, int length, String code, String... issueData) {
		decoratee.acceptInfo(message, object, offset, length, checkCode(code), issueData)
	}
	
	override acceptWarning(String message, EObject object, EStructuralFeature feature, int index, String code, String... issueData) {
		decoratee.acceptWarning(message, object, feature, index, checkCode(code), issueData)
	}
	
	override acceptWarning(String message, EObject object, int offset, int length, String code, String... issueData) {
		decoratee.acceptWarning(message, object, offset, length, checkCode(code), issueData)
	}
	
}