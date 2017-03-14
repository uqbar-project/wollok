package org.uqbar.project.wollok.semantics

import com.google.inject.Inject
import it.xsemantics.runtime.RuleEnvironment
import it.xsemantics.runtime.validation.XsemanticsValidatorErrorGenerator
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.uqbar.project.wollok.validation.DecoratedValidationMessageAcceptor
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Extends the xsemantics generated class to customize error messages
 * 
 * @author jfernandes
 */
class ExtendedXSemanticsWollokDsl extends WollokDslTypeSystem {
	@Inject XsemanticsValidatorErrorGenerator errorGenerator
	
	def validate(WFile file, WollokDslValidator validator) {
		var RuleEnvironment env = this.emptyEnvironment
		errorGenerator.generateErrors(decorateErrorAcceptor(validator, WollokDslValidator.TYPE_SYSTEM_ERROR),
			this.inferTypes(env, file.main), file.main)
	}
	
	def decorateErrorAcceptor(ValidationMessageAcceptor a, String defaultCode) {
		new DecoratedValidationMessageAcceptor(a, defaultCode)
	}
	
}