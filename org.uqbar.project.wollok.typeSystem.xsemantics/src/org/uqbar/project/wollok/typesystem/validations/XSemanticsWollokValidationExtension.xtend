package org.uqbar.project.wollok.typesystem.validations

import com.google.inject.Inject
import it.xsemantics.runtime.RuleEnvironment
import it.xsemantics.runtime.validation.XsemanticsValidatorErrorGenerator
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem
import org.uqbar.project.wollok.validation.DecoratedValidationMessageAcceptor
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.validation.WollokValidatorExtension
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.eclipse.core.runtime.AssertionFailedException

/**
 * 
 * @author jfernandes
 * @author tesonep 
 */
class XSemanticsWollokValidationExtension extends WollokDslTypeSystem implements WollokValidatorExtension {
	@Inject IPreferenceStoreAccess preferenceStoreAccess;
	@Inject XsemanticsValidatorErrorGenerator errorGenerator

	// pasar a otra clase con constantes de preferencias
	public static val TYPE_SYSTEM_CHECKS_ENABLED = "TYPE_SYSTEM_CHECKS_ENABLED"

	override check(WFile file, WollokDslValidator validator) {
		//TODO: lee las preferencias cada vez!
		try
			if (!preferences(file).getBoolean(TYPE_SYSTEM_CHECKS_ENABLED))
				return
		catch (IllegalStateException e) {
			// headless launcher doesn't open workspace, so this fails.
			// but it's ok since the type system won't run in runtime. 
			return;
		}
		catch (AssertionFailedException e) 
			return;

		var RuleEnvironment env = this.emptyEnvironment
		errorGenerator.generateErrors(decorateErrorAcceptor(validator, WollokDslValidator.TYPE_SYSTEM_ERROR),
			this.inferTypes(env, file.body), file.body)
	}

	def preferences(EObject obj) {
		preferenceStoreAccess.getContextPreferenceStore(obj.IFile.project)
	}

	def decorateErrorAcceptor(ValidationMessageAcceptor a, String defaultCode) {
		new DecoratedValidationMessageAcceptor(a, defaultCode)
	}

}
