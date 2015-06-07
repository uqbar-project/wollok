package org.uqbar.project.wollok.validation

import java.util.List
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.wollokDsl.WAssignment
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WBlockExpression
import org.uqbar.project.wollok.wollokDsl.WCatch
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WClosure
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WExpression
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WLibrary
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WNamed
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.uqbar.project.wollok.wollokDsl.WPostfixOperation
import org.uqbar.project.wollok.wollokDsl.WProgram
import org.uqbar.project.wollok.wollokDsl.WReferenciable
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation
import org.uqbar.project.wollok.wollokDsl.WTest
import org.uqbar.project.wollok.wollokDsl.WTry
import org.uqbar.project.wollok.wollokDsl.WVariableDeclaration
import org.uqbar.project.wollok.wollokDsl.WVariableReference

import static org.uqbar.project.wollok.Messages.*
import static org.uqbar.project.wollok.wollokDsl.WollokDslPackage.Literals.*

import static extension org.uqbar.project.wollok.WollokDSLKeywords.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import org.uqbar.project.wollok.wollokDsl.WVariable

/**
 * Custom validation rules.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 * 
 * @author jfernandes
 */
// TODO: abstract a new generic Validator that is integrated with a preferences mechanism
// that will allow to enabled/disabled checks, and maybe even configure the issue severity for some
// like "error/warning/ignore". It could be completely automatically based on annotations.
// Ex:
//  @Check @ConfigurableSeverity @EnabledDisabled
class WollokDslValidator extends AbstractWollokDslValidator {
	List<WollokValidatorExtension> wollokValidatorExtensions

	// ERROR KEYS	
	public static val CANNOT_ASSIGN_TO_VAL = "CANNOT_ASSIGN_TO_VAL"
	public static val CANNOT_ASSIGN_TO_NON_MODIFIABLE = "CANNOT_ASSIGN_TO_NON_MODIFIABLE"
	public static val CANNOT_INSTANTIATE_ABSTRACT_CLASS = "CANNOT_INSTANTIATE_ABSTRACT_CLASS"
	public static val CLASS_NAME_MUST_START_UPPERCASE = "CLASS_NAME_MUST_START_UPPERCASE"
	public static val REFERENCIABLE_NAME_MUST_START_LOWERCASE = "REFERENCIABLE_NAME_MUST_START_LOWERCASE"
	public static val METHOD_ON_THIS_DOESNT_EXIST = "METHOD_ON_THIS_DOESNT_EXIST"
	public static val METHOD_MUST_HAVE_OVERRIDE_KEYWORD = "METHOD_MUST_HAVE_OVERRIDE_KEYWORD" 
	public static val ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS = "ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS"
	public static val TYPE_SYSTEM_ERROR = "TYPE_SYSTEM_ERROR"
	
	// WARNING KEYS
	public static val WARNING_UNUSED_VARIABLE = "WARNING_UNUSED_VARIABLE"
	
	
	def validatorExtensions(){
		if(wollokValidatorExtensions != null)
			return wollokValidatorExtensions
			
		val configs = Platform.getExtensionRegistry.getConfigurationElementsFor("org.uqbar.project.wollok.wollokValidationExtension")
		wollokValidatorExtensions = configs.map[it.createExecutableExtension("class") as WollokValidatorExtension]
	}
	
	@Check
	def checkValidationExtensions(WFile wfile){
		validatorExtensions.forEach[ check(wfile, this)]
	}
	
	@Check
	def classNameMustStartWithUpperCase(WClass c) {
		if (Character.isLowerCase(c.name.charAt(0))) error(WollokDslValidator_CLASS_NAME_MUST_START_UPPERCASE, c, WNAMED__NAME, CLASS_NAME_MUST_START_UPPERCASE)
	}
	
	@Check
	def referenciableNameMustStartWithLowerCase(WReferenciable c) {
		if (Character.isUpperCase(c.name.charAt(0))) error(WollokDslValidator_REFERENCIABLE_NAME_MUST_START_LOWERCASE, c, WNAMED__NAME, REFERENCIABLE_NAME_MUST_START_LOWERCASE)
	}

	@Check
	def checkCannotInstantiateAbstractClasses(WConstructorCall c) {
		if(c.classRef.isAbstract) error(WollokDslValidator_CANNOT_INSTANTIATE_ABSTRACT_CLASS, c, WCONSTRUCTOR_CALL__CLASS_REF, CANNOT_INSTANTIATE_ABSTRACT_CLASS)
	}

	@Check
	def checkConstructorCall(WConstructorCall c) {
		if (!c.isValidConstructorCall()) {
			val expectedMessage = if (c.classRef.constructor == null)
					""
				else
					c.classRef.constructor.parameters.map[name].join(",")
			error(WollokDslValidator_WCONSTRUCTOR_CALL__ARGUMENTS + "(" + expectedMessage + ")", c, WCONSTRUCTOR_CALL__ARGUMENTS)
		}
	}

	@Check
	def checkMethodActuallyOverrides(WMethodDeclaration m) {
		val overrides = m.actuallyOverrides
		if(m.overrides && !overrides) m.error(WollokDslValidator_METHOD_NOT_OVERRIDING)
		if (overrides && !m.overrides)
			m.error(WollokDslValidator_METHOD_MUST_HAVE_OVERRIDE_KEYWORD, METHOD_MUST_HAVE_OVERRIDE_KEYWORD)
	}

	@Check
	def checkCannotAssignToVal(WAssignment a) {
		if(!a.feature.ref.isModifiableFrom(a)) error(WollokDslValidator_CANNOT_MODIFY_VAL, a, WASSIGNMENT__FEATURE, cannotModifyErrorId(a.feature))
	}
	def dispatch String cannotModifyErrorId(WReferenciable it) { CANNOT_ASSIGN_TO_NON_MODIFIABLE }
	def dispatch String cannotModifyErrorId(WVariableDeclaration it) { CANNOT_ASSIGN_TO_VAL }
	def dispatch String cannotModifyErrorId(WVariableReference it) { cannotModifyErrorId(ref) }

	@Check
	def duplicated(WMethodDeclaration m) {
		// can we allow methods with same name but different arg size ? 
		if (m.declaringContext.members.filter(WMethodDeclaration).exists[it != m && it.name == m.name])
			m.error(WollokDslValidator_DUPLICATED_METHOD)
	}

	@Check
	def duplicated(WReferenciable p) {
		if(p.isDuplicated) p.error(WollokDslValidator_DUPLICATED_NAME)
	}

	@Check
	def methodInvocationToThisMustExist(WMemberFeatureCall call) {
		if (call.callOnThis && call.method != null && !call.method.declaringContext.isValidCall(call)) {
			error(WollokDslValidator_METHOD_ON_THIS_DOESNT_EXIST, call, WMEMBER_FEATURE_CALL__FEATURE, METHOD_ON_THIS_DOESNT_EXIST)
		}
	}

	@Check
	def unusedVariables(WVariableDeclaration it) {
		val assignments = variable.assignments
		if (assignments.empty) {
			if (writeable)
				warning(WollokDslValidator_WARN_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE)
			else if (!writeable)
				error(WollokDslValidator_ERROR_VARIABLE_NEVER_ASSIGNED, it, WVARIABLE_DECLARATION__VARIABLE)	
		}
		if (variable.uses.empty)
			warning(WollokDslValidator_VARIABLE_NEVER_USED, it, WVARIABLE_DECLARATION__VARIABLE, WARNING_UNUSED_VARIABLE)
	}
	
	@Check
	def superInvocationOnlyInValidMethod(WSuperInvocation sup) {
		val body = sup.method.expression as WBlockExpression
		if (sup.method.declaringContext instanceof WObjectLiteral)
			error(WollokDslValidator_SUPER_ONLY_IN_CLASSES, body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
		else if (!sup.method.overrides)
			error(WollokDslValidator_SUPER_ONLY_OVERRIDING_METHOD, body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
		else if (sup.memberCallArguments.size != sup.method.parameters.size)
			error('''«WollokDslValidator_SUPER_INCORRECT_ARGS» «sup.method.parameters.size»: «sup.method.overridenMethod.parameters.map[name].join(", ")»''', body, WBLOCK_EXPRESSION__EXPRESSIONS, body.expressions.indexOf(sup))
	}
	
	// ***********************
	// ** Exceptions
	// ***********************
	
	@Check
	def tryMustHaveEitherCatchOrAlways(WTry tri) {
		if ((tri.catchBlocks == null || tri.catchBlocks.empty) && tri.alwaysExpression == null)
			error(WollokDslValidator_ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS, tri, WTRY__EXPRESSION, ERROR_TRY_WITHOUT_CATCH_OR_ALWAYS)
	}
	
	@Check 
	def catchExceptionTypeMustExtendException(WCatch it) {
		if (!exceptionType.exception) error(WollokDslValidator_CATCH_ONLY_EXCEPTION, it, WCATCH__EXCEPTION_TYPE)
	}
	
// requires type system in order to infer type of the WExpression being thrown ! "throw <??>"
//	@Check
//	def canOnlyThrowExceptionTypeObjects(WThrow it) {
//		if (!it.exception.type.isException) error("Can only throw wollok.lang.Exception or a subclass of it", it, WCATCH__EXCEPTION_TYPE)
//	}
	
	@Check
	def postFixOpOnlyValidforVarReferences(WPostfixOperation op) {
		if (!(op.operand.isWritableVarRef))
			error(op.feature + WollokDslValidator_POSTFIX_ONLY_FOR_VAR, op, WPOSTFIX_OPERATION__OPERAND)
	}
	
	@Check
	def classNameCannotBeDuplicatedWithinPackage(WPackage p) {
		val classes = p.elements.filter(WClass)
		val repeated = classes.filter[c| classes.exists[it != c && name == c.name] ]
		repeated.forEach[
			error(WollokDslValidator_DUPLICATED_CLASS_IN_PACKAGE + p.name, it, WNAMED__NAME)
		]
	}
	
	@Check 
	def avoidDuplicatedPackageName(WPackage p) {
		if (p.eContainer.eContents.filter(WPackage).exists[it != p && name == p.name])
			error(WollokDslValidator_DUPLICATED_PACKAGE + " " + p.name, p, WNAMED__NAME)
	}
	
	@Check
	def multiOpOnlyValidforVarReferences(WBinaryOperation op) {
		if (op.feature.isMultiOpAssignment && !op.leftOperand.isWritableVarRef)
			error(op.feature + WollokDslValidator_BINARYOP_ONLY_ON_VARS, op, WBINARY_OPERATION__LEFT_OPERAND)
	}
	
	@Check
	def programInProgramFile(WProgram p){
		if(p.eResource.URI.nonXPectFileExtension != WollokConstants.PROGRAM_EXTENSION)
			error(WollokDslValidator_PROGRAM_IN_FILE + ''' «WollokConstants.PROGRAM_EXTENSION»''', p, WPROGRAM__NAME)					
	}

	@Check
	def libraryInLibraryFile(WLibrary l){
		if(l.eResource.URI.nonXPectFileExtension != WollokConstants.CLASS_OBJECTS_EXTENSION) 
			error(WollokDslValidator_CLASSES_IN_FILE + ''' «WollokConstants.CLASS_OBJECTS_EXTENSION»''', l, WLIBRARY__ELEMENTS)		
	}

	def isWritableVarRef(WExpression e) { 
		e instanceof WVariableReference
		&& (e as WVariableReference).ref instanceof WVariable
		&& ((e as WVariableReference).ref as WVariable).eContainer instanceof WVariableDeclaration
		&& (((e as WVariableReference).ref as WVariable).eContainer as WVariableDeclaration).writeable
	}

	/**
	 * Returns the "wollok" file extension o a file, ignoring a possible final ".xt"
	 * 
	 * This is a workaround for XPext testing. XPect test definition requires to add ".xt" to program file names, 
	 * therefore fileExtension-dependent validations will fail if this is not taken into account.
	 */
	def nonXPectFileExtension(URI uri) {
		if (uri.fileExtension == 'xt') {
			val fileName = uri.segments.last()
			val fileNameParts = fileName.split("\\.")
			fileNameParts.get(fileNameParts.length - 2) // Penultimate part (last part is .xt)
		}
		else uri.fileExtension
	}

	// ******************************	
	// ** native methods
	// ******************************
	
	@Check
	def nativeMethodsChecks(WMethodDeclaration it) {
		if (native) {
			 if (expression != null) error("Native methods cannot have a body", it, WMETHOD_DECLARATION__EXPRESSION)
			 if (overrides) error("Native methods cannot override anything", it, WMETHOD_DECLARATION__OVERRIDES)
			 if (declaringContext instanceof WObjectLiteral) error("Native methods can only be defined in classes", it, WMETHOD_DECLARATION__NATIVE)
			 // this is currently a limitation on native objects
//			 if(declaringContext instanceof WClass)
//				 if ((declaringContext as WClass).parent != null && (declaringContext as WClass).parent.native)
//				 	error(WollokDslValidator_NATIVE_IN_NATIVE_SUBCLASS, it, WMETHOD_DECLARATION__NATIVE)
		}
	}

	// ******************************
	// ** is duplicated impl (TODO: move it to extensions)
	// ******************************
	
	def boolean isDuplicated(WReferenciable reference) {
		reference.eContainer.isDuplicated(reference)
	}

	// Root objects (que no tiene acceso a variables fuera de ellos)
	def dispatch boolean isDuplicated(WClass c, WReferenciable v) { c.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WProgram p, WReferenciable v) {  p.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WTest p, WReferenciable v) { p.variables.existsMoreThanOne(v) }
	def dispatch boolean isDuplicated(WLibrary wl, WReferenciable r){ wl.elements.existsMoreThanOne(r) }
	def dispatch boolean isDuplicated(WNamedObject c, WReferenciable r) { c.variables.existsMoreThanOne(r) }

	def dispatch boolean isDuplicated(WPackage p, WNamedObject r){
		p.namedObjects.existsMoreThanOne(r)
	}

	def dispatch boolean isDuplicated(WMethodDeclaration m, WReferenciable v) {
		m.parameters.existsMoreThanOne(v) || m.declaringContext.isDuplicated(v)
	}

	def dispatch boolean isDuplicated(WBlockExpression c, WReferenciable v) {
		c.expressions.existsMoreThanOne(v) || c.eContainer.isDuplicated(v)
	}

	def dispatch boolean isDuplicated(WClosure c, WReferenciable r) {
		c.parameters.existsMoreThanOne(r) || c.eContainer.isDuplicated(r)
	}

	def dispatch boolean isDuplicated(WConstructor c, WReferenciable r) {
		c.parameters.existsMoreThanOne(r) || c.eContainer.isDuplicated(r)
	}

	// default case is to delegate up to container
	def dispatch boolean isDuplicated(EObject e, WReferenciable r) {
		e.eContainer.isDuplicated(r)
	}

	def existsMoreThanOne(Iterable<?> exps, WReferenciable ref) {
		exps.filter(WReferenciable).exists[it != ref && name == ref.name]
	}

	// ******************************
	// ** extensions to validations.
	// ******************************
	
	def error(WNamed e, String message) { error(message, e, WNAMED__NAME) }
	def error(WNamed e, String message, String errorId) { error(message, e, WNAMED__NAME, errorId) }
		
}
