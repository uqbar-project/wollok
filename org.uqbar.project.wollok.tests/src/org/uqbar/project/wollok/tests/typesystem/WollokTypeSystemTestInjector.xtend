package org.uqbar.project.wollok.tests.typesystem

import com.google.inject.Inject
import org.eclipse.xpect.setup.XpectGuiceModule
import org.eclipse.xtext.service.SingletonBinding
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.tests.injectors.WollokTestModule
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.validation.WollokValidatorExtension
import org.uqbar.project.wollok.wollokDsl.WFile

@XpectGuiceModule
class WollokTypeSystemTestModule extends WollokTestModule {
	new(){
		super(new WollokLauncherParameters)
	}

	new(WollokLauncherParameters params) {
		super(params)
	}

	@SingletonBinding(eager=true)
	override Class<? extends WollokDslValidator> bindWollokDslValidator() {
		WollokTypeSystemTestValidator
	}
	
	@SingletonBinding
	def Class<? extends TypeSystem> bindTypeSystem() {
		ConstraintBasedTypeSystem
	}
}

class WollokTypeSystemTestValidator extends WollokDslValidator {
	@Inject TypeSystem typeSystem

	override validatorExtensions() {
		#[new TypeSystemTestValidatorExtension(typeSystem)]
	}
}

class TypeSystemTestValidatorExtension implements WollokValidatorExtension {
	TypeSystem typeSystem

	new(TypeSystem typeSystem) {
		this.typeSystem = typeSystem
	}

	@Check(NORMAL)
	override check(WFile file, WollokDslValidator validator) {
		typeSystem.initialize(file)
		typeSystem.analyse(file)
		typeSystem.inferTypes()
		typeSystem.validate(file, validator)
	}
}
