package org.uqbar.project.wollok.validation

import com.google.inject.Inject
import java.lang.reflect.Method
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.ui.editor.preferences.IPreferenceStoreAccess
import org.eclipse.xtext.validation.AbstractDeclarativeValidator
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.preferences.WollokCachedTypeSystemPreferences
import org.uqbar.project.wollok.utils.WEclipseUtils
import org.uqbar.project.wollok.wollokDsl.WNamed

import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.uqbar.project.wollok.utils.XtendExtensions.*

/**
 * Intermediate superclass to avoid mixing up "fwk-like" logic
 * from the actual rules and checks.
 * 
 * @author jfernandes
 */
class AbstractConfigurableDslValidator extends AbstractWollokDslValidator implements ConfigurableDslValidator {
	@Inject IPreferenceStoreAccess preferenceStoreAccess

	// ******************************
	// ** extensions to validations.
	// ******************************
	def report(WNamed e, String message) { report(message, e, WNAMED__NAME) }

	def report(WNamed e, String message, String errorId) { report(message, e, WNAMED__NAME, errorId) }

	override report(String message, EObject obj) {
		val containingFeature = obj.eContainingFeature
		if(containingFeature.isMany) {
			report(
				message,
				obj.eContainer,
				containingFeature,
				(obj.eContainer.eGet(containingFeature) as List<?>).indexOf(obj)
			)
		} else {
			report(
				message,
				obj.eContainer,
				containingFeature
			)
		}
	}

	def preferences(EObject obj) {
		if(WEclipseUtils.isWorkspaceOpen) {
			val ifile = obj.IFile
			if(ifile !== null) {
				return preferenceStoreAccess.getContextPreferenceStore(ifile.project)
			}
		}
		null
	}

	// ******************************** 
	// configurable severity
	// the report() methods sucks, they have kind of repeated code
	// because the superclasses have different methods for different parameters :(
	// I'm stopping the refactor here.
	// ******************************
	def report(String message, EObject source, EStructuralFeature feature) {
		report(message, source, feature, INSIGNIFICANT_INDEX)
	}

	def reportEObject(String description, EObject invalidObject, String issueId) {
		reportEObject(description, invalidObject, issueId, CheckSeverity.ERROR)
	}

	def reportEObject(String description, EObject invalidObject, String issueId, CheckSeverity severity) {
		val severityValue = calculateSeverity(invalidObject) ?: severity
		val length = invalidObject.after - invalidObject.before
		generateIssue(severityValue, description, invalidObject, invalidObject.before, length, issueId)
	}

	def generateIssue(CheckSeverity severity, String description, EObject invalidObject, int before, int length,
		String issueId) {
		switch (severity) {
			case ERROR:
				messageAcceptor.acceptError(description, invalidObject, before, length, issueId)
			case WARN:
				messageAcceptor.acceptWarning(description, invalidObject, before, length, issueId)
			case INFO:
				messageAcceptor.acceptInfo(description, invalidObject, before, length, issueId)
			case IGNORE:
				doNothing
		}

	}

	def report(String description, EObject invalidObject, EStructuralFeature ref, String issueId) {
		val severityValue = calculateSeverity(invalidObject)

		if(severityValue === null)
			error(description, invalidObject, ref, issueId)
		switch (severityValue) {
			case ERROR: error(description, invalidObject, ref, issueId)
			case WARN: warning(description, invalidObject, ref, issueId)
			case INFO: info(description, invalidObject, ref, issueId)
			case IGNORE: doNothing
		}
	}

	def report(String description, EObject invalidObject, EStructuralFeature ref, int index) {
		report(description, invalidObject, ref, index, null)
	}

	def report(String description, EObject invalidObject, EStructuralFeature ref, int index, String issueId) {
		val severityValue = calculateSeverity(invalidObject)

		if(severityValue === null)
			error(description, invalidObject, ref, index, issueId)
		switch (severityValue) {
			case ERROR: error(description, invalidObject, ref, index, issueId)
			case WARN: warning(description, invalidObject, ref, index, issueId)
			case INFO: info(description, invalidObject, ref, index, issueId)
			case IGNORE: doNothing
		}
	}

	def calculateSeverity(EObject invalidObject) {
		val checkMethod = inferCheckMethod()
		val prefs = preferences(invalidObject)
		var severityValue = prefs?.getString(checkMethod.name)?.severityEnumValue
		if(severityValue === null)
			severityValue = checkMethod.getAnnotation(DefaultSeverity)?.value
		if(severityValue === null)
			severityValue = WollokCachedTypeSystemPreferences.instance.typeSystemSeverity
		severityValue
	}

	def inferCheckMethod() {
		val stackTrace = try
			throw new RuntimeException()
		catch(RuntimeException e)
			e.stackTrace
		val checkStackElement = stackTrace.findLast [ e |
			val m = this.class.methods.findFirst[name == e.methodName]
			m !== null && m.isAnnotationPresent(Check)
		]
		return this.class.methods.findFirst[m|m.name == checkStackElement.methodName]
	}

	def getSeverityEnumValue(String value) {
		if(value === null || "".equals(value.trim)) null else CheckSeverity.valueOf(value)
	}

	/** overrides to add the enabled/disabled behavior */
	override protected createMethodWrapper(AbstractDeclarativeValidator instanceToUse, Method method) {
		new MethodWrapperDecorator(super.createMethodWrapper(instanceToUse, method),
			instanceToUse as WollokDslValidator)
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
			if(method.isAnnotationPresent(NotConfigurable) || prefs === null || !prefs.contains(key) ||
				prefs.getBoolean(key)) {
				decoratee.invoke(state)
			} else {
			}
		}
	}

	// DUPLICATED / UNIFY WITH QuickFixUtils
	def static before(EObject element) {
		element.node.offset
	}

	def static after(EObject element) {
		element.node.endOffset
	}

	def static node(EObject element) {
		NodeModelUtils.findActualNodeFor(element)
	}

}
