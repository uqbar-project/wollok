package org.uqbar.project.wollok.tests.typesystem

import com.google.inject.Guice
import com.google.inject.Inject
import org.eclipse.xtext.service.SingletonBinding
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherModule
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.tests.injectors.WollokTestInjector
import org.uqbar.project.wollok.typesystem.TypeSystem
import org.uqbar.project.wollok.typesystem.constraints.ConstraintBasedTypeSystem
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.validation.WollokValidatorExtension
import org.uqbar.project.wollok.wollokDsl.WFile
import org.xpect.setup.XpectGuiceModule

//	public Injector createInjector() {
//		return Guice.createInjector(new org.xpect.XpectRuntimeModule());
//	}
//	


class WollokTypeSystemTestInjector extends WollokTestInjector {
	override protected internalCreateInjector() {
		new WollokTypeSystemTestSetup().createInjectorAndDoEMFRegistration
	}

}

class WollokTypeSystemTestSetup extends WollokLauncherSetup {
	override createInjector() {
		return Guice.createInjector(new WollokTypeSysteTestModule(), this);
	}
}

@XpectGuiceModule
class WollokTypeSysteTestModule extends WollokLauncherModule {
	new() {
		super(new WollokLauncherParameters)
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

	override check(WFile file, WollokDslValidator validator) {
		typeSystem.validate(file, validator)
	}
}
