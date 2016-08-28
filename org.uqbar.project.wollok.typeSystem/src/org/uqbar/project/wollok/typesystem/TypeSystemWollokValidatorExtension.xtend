package org.uqbar.project.wollok.typesystem

import com.google.inject.Inject
import org.eclipse.core.runtime.AssertionFailedException
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
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
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
	override check(WFile file, WollokDslValidator validator) {
		//TODO: lee las preferencias cada vez!
		try
			if (!preferences(file).getBoolean(WollokTypeSystemActivator.PREF_TYPE_SYSTEM_CHECKS_ENABLED))
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
	
	def preferences(EObject obj) {
		preferenceStoreAccess.getContextPreferenceStore(obj.IFile.project)
	}
	
}