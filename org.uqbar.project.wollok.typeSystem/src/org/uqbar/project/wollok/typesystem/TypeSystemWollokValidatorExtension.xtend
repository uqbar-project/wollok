package org.uqbar.project.wollok.typesystem

import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.utils.WEclipseUtils
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.validation.WollokValidatorExtension
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * A validator extension that runs the currently configured type system to
 * check types.
 * 
 * @author jfernandes
 */
class TypeSystemWollokValidatorExtension implements WollokValidatorExtension {

	@Check(FAST)
	override check(WFile file, WollokDslValidator validator) {
		WollokTypeSystemActivator.^default.ifEnabledFor(file.project) [ ts |
			ts.reportErrors(file.eResource, validator)
		]
	}
}
