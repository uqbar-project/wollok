package org.uqbar.project.wollok.validation

import com.google.inject.Inject
import java.lang.reflect.Method
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.validation.AbstractDeclarativeValidator
import org.uqbar.project.wollok.utils.WEclipseUtils
import org.uqbar.project.wollok.wollokDsl.WNamed

import static org.uqbar.project.wollok.validation.AbstractConfigurableDslValidator.*
import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * Intermediate superclass to avoid mixing up "fwk-like" logic
 * from the actual rules and checks.
 * 
 * @author jfernandes
 */
class AbstractConfigurableDslValidator extends AbstractWollokDslValidator {
	@Inject IPreferenceStoreAccess preferenceStoreAccess
	
		// ******************************
	// ** extensions to validations.
	// ******************************
	
	def report(WNamed e, String message) { report(message, e, WNAMED__NAME) }
	def report(WNamed e, String message, String errorId) { report(message, e, WNAMED__NAME, errorId) }
		
	def report(String message, EObject obj) {
		report(message, obj.eContainer, obj.eContainingFeature)
	}
	
	def preferences(EObject obj) {
		if (WEclipseUtils.isWorkspaceOpen) {
			val ifile = obj.IFile
			if (ifile != null) {
				return preferenceStoreAccess.getContextPreferenceStore(ifile.project)
			}
		}
		null
	}
	
	// ******************************
	// ** configurable severity
	//   the report() methods sucks, they have kind of repeated code
	//   because the superclasses have different methods for different parameters :(
	//   I'm stopping the refactor here.
	// ******************************
	def report(String message, EObject source, EStructuralFeature feature) {
		report(message, source, feature, INSIGNIFICANT_INDEX)
	}
	
	def report(String description, EObject invalidObject, EStructuralFeature ref, String issueId) {
		val severityValue = calculateSeverity(invalidObject)
		
		if (severityValue == null)
			error(description, invalidObject, ref, issueId)
		switch (severityValue) {
			case ERROR : error(description, invalidObject, ref, issueId)
			case WARN : warning(description, invalidObject, ref, issueId)
			case INFO : info(description, invalidObject, ref, issueId) 
		}
	}
	
	def report(String description, EObject invalidObject, EStructuralFeature ref, int index) {
		report(description, invalidObject, ref, index, null)
	}
	
	def report(String description, EObject invalidObject, EStructuralFeature ref, int index, String issueId) {
		val severityValue = calculateSeverity(invalidObject)
		
		if (severityValue == null)
			error(description, invalidObject, ref, index, issueId)
		switch (severityValue) {
			case ERROR : error(description, invalidObject, ref, index, issueId)
			case WARN : warning(description, invalidObject, ref, index, issueId)
			case INFO : info(description, invalidObject, ref, index, issueId) 
		}
	}
	
	def calculateSeverity(EObject invalidObject) {
		val checkMethod = inferCheckMethod()
		val prefs = preferences(invalidObject)
		var severityValue = prefs?.getString(checkMethod.name)?.severityEnumValue
		if (severityValue == null)
			severityValue = checkMethod.getAnnotation(DefaultSeverity)?.value
		severityValue
	}
	
	def inferCheckMethod() {
		val stackTrace = try throw new RuntimeException() catch(RuntimeException e) e.stackTrace
		val checkStackElement = stackTrace.get(3)
		return this.class.methods.findFirst[m | m.name == checkStackElement.methodName]
	}
	
	def getSeverityEnumValue(String value) {
		if (value == null || "".equals(value.trim)) null else CheckSeverity.valueOf(value)
	}

	/** overrides to add the enabled/disabled behavior */
	override protected createMethodWrapper(AbstractDeclarativeValidator instanceToUse, Method method) {
		new MethodWrapperDecorator(super.createMethodWrapper(instanceToUse, method), instanceToUse as WollokDslValidator)
	}
	
	public static val String PREF_KEY_ENABLED_SUFFIX = ".enabled"
	
	static class MethodWrapperDecorator extends MethodWrapper {
		val MethodWrapper decoratee
	
		protected new(MethodWrapper decoratee, WollokDslValidator validator) {
			super(validator, decoratee.method)
			this.decoratee = decoratee
		}
		
		override getInstance() {
			decoratee.instance
		}
		
		override getMethod() {
			decoratee.method
		}
		
		override isMatching(Class<?> param) {
			decoratee.isMatching(param)
		}
		
		override invoke(State state) {
			val prefs = (instance as WollokDslValidator).preferences(state.currentObject)
			val key = method.name + PREF_KEY_ENABLED_SUFFIX
			// default is "enabled" if not present
			if (method.isAnnotationPresent(NotConfigurable) || prefs == null || !prefs.contains(key) || prefs.getBoolean(key)) {
				decoratee.invoke(state)
			}
			else {
			}
		}
	}
	
}