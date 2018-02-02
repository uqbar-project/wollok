package org.uqbar.project.wollok.typesystem.exceptions

import org.eclipse.emf.ecore.EObject
import org.uqbar.project.wollok.typesystem.TypeSystemException

import static org.uqbar.project.wollok.Messages.*

class CannotBeVoidException extends TypeSystemException {
	/**
	 * A semantic element that was tried to be assigned to {@link WVoid} but
	 * its nature forbids it.
	 */
	EObject object
	
	new(EObject object) { this.object = object }
	
	override getMessage() { WollokTypeSystem_AN_EXPRESSION_IS_EXPECTED_AT_THIS_POSITION }
}