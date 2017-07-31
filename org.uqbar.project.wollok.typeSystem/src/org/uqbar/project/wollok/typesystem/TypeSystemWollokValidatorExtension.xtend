package org.uqbar.project.wollok.typesystem

import org.eclipse.core.runtime.AssertionFailedException
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.validation.WollokValidatorExtension
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * A validator extension that runs the currently configured type system to
 * check types.
 * 
 * @author jfernandes
 */
class TypeSystemWollokValidatorExtension implements WollokValidatorExtension {

	@Check(NORMAL)
	override check(WFile file, WollokDslValidator validator) {
		//TODO: lee las preferencias cada vez!
		try
			if (!WollokTypeSystemActivator.^default.isTypeSystemEnabled(file))
				return
		catch (IllegalStateException e) {
			// headless launcher doesn't open workspace, so this fails.
			// but it's ok since the type system won't run in runtime. 
			return
		}
		catch (AssertionFailedException e) 
			return;
		
		WollokTypeSystemActivator.^default.getTypeSystem(file).validate(file, validator)		
	}
	
}