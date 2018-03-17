package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.typesystem.exceptions.CannotBeVoidException
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.*
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo.*
import static extension org.uqbar.project.wollok.scoping.WollokResourceCache.isCoreObject
interface ITypeVariable {
	def EObject getOwner()

	def void beSubtypeOf(TypeVariable variable)

	def void beSupertypeOf(TypeVariable variable)
}

class TypeVariable implements ITypeVariable {
	val Logger log = Logger.getLogger(class)

	@Accessors
	val EObject owner

	/**
	 * Type info starts in null and will be coerced to one of the type info kinds (simple or closure) when we have information related to it.
	 * Therefore, a variable with a null type info is a variable for which we have no information yet.
	 */
	@Accessors(PUBLIC_GETTER)
	var TypeInfo typeInfo

	@Accessors
	val Set<TypeVariable> subtypes = newHashSet

	@Accessors
	val Set<TypeVariable> supertypes = newHashSet

	List<TypeSystemException> errors = newArrayList

	new(EObject owner) {
		this.owner = owner
	}

	def static simple(EObject owner) {
		new TypeVariable(owner)
	}

	def static newVoid(EObject owner) {
		new TypeVariable(owner) => [setTypeInfo(new VoidTypeInfo())]
	}

	def static closure(EObject owner, List<ITypeVariable> parameters, ITypeVariable returnType) {
		new TypeVariable(owner) => [setTypeInfo(new ClosureTypeInfo(parameters, returnType))]
	}

	def static generic(EObject owner, List<String> typeParameterNames) {
		new TypeVariable(owner) => [setTypeInfo(new GenericTypeInfo(typeParameterNames.toInvertedMap[synthetic]))]
	}

	def static classParameter(EObject owner, String paramName) {
		new ClassParameterTypeVariable(owner, paramName)
	}

	def static synthetic() {
		simple(null)
	}

// ************************************************************************
// ** For the TypeSystem implementation
// ************************************************************************
	def getType() {
		if (typeInfo !== null) typeInfo.getType(this) else WollokType.WAny
	}

// ************************************************************************
// ** Errors
// ************************************************************************
	/**
	 * Informs if an error has been detected for this variable.
	 * In the case that this variable has no type info, this means it has not yet been used, 
	 * so we assume to have no errors.
	 */
	def hasErrors() {
		return !errors.empty
	}

	def addError(TypeSystemException exception) {
		if (owner.isCoreObject) 
			throw new RuntimeException('''Tried to add a type error to a core object: «owner.debugInfoInContext»''')
		
		log.info('''Error reported in «this.fullDescription»''')
		errors.add(exception)
	}

	// REVIEW Is it necessary to pass 'user'?
	def reportErrors(ConfigurableDslValidator validator) {
		errors.forEach [
			log.debug('''Reporting error in «variable.owner.debugInfo»: «message»''')
			try {
				validator.report(message, variable.owner)
			}
			catch (IllegalArgumentException exception) {
				// We probably reported a type error to a core object, which is not possible
				log.error(exception.message, exception)
			}
		]
	}

	// ************************************************************************
	// ** Adding constraints
	// ************************************************************************
	override beSupertypeOf(TypeVariable subtype) {
		this.addSubtype(subtype)
		subtype.addSupertype(this)
	}

	override beSubtypeOf(TypeVariable supertype) {
		this.addSupertype(supertype)
		supertype.addSubtype(this)
	}

	/**
	 * Internal method, do not call directly, use {@link #beSupertypeOf(TypeVariable)} instead.
	 */
	protected def addSubtype(TypeVariable subtype) {
		this.subtypes.add(subtype)
		if (typeInfo !== null) typeInfo.subtypeAdded()
	}

	/**
	 * Internal method, do not call directly, use {@link #beSupertypeOf(TypeVariable)} instead.
	 */
	protected def addSupertype(TypeVariable supertype) {
		this.supertypes.add(supertype)
		if (typeInfo !== null) typeInfo.supertypeAdded()
	}

	def beVoid() {
		setTypeInfo(new VoidTypeInfo())
	}

	// ************************************************************************
	// ** Adding / accessing type info
	// ************************************************************************
	def dispatch void setTypeInfo(TypeInfo newTypeInfo) {
		doSetTypeInfo(newTypeInfo)
	}

	def dispatch void setTypeInfo(VoidTypeInfo newTypeInfo) {
		if (typeInfo.isVoid) {
			return
		} else if (typeInfo === null && owner.canBeVoid) {
			doSetTypeInfo(newTypeInfo)
		} else {
			throw new CannotBeVoidException(owner)
		}
	}

	def doSetTypeInfo(TypeInfo newTypeInfo) {
		newTypeInfo.addUser(this)
		this.typeInfo = newTypeInfo
	}

	/**
	 * Adds a minType to this variable. This is only possible for simple types. 
	 * Therefore, if type info has not yet been assigned, it will be forced to a simple type. 
	 * If the variable points to a closure type this will produce a type error.
	 * 
	 * @throws TypeSystemException if the new minType is a type error.
	 */
	def addMinType(WollokType type) {
		if (typeInfo === null) setTypeInfo(new SimpleTypeInfo())
		typeInfo.addMinType(type)
	}

	def boolean setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable origin) {
		if (typeInfo === null) setTypeInfo(new SimpleTypeInfo())
		typeInfo.setMaximalConcreteTypes(maxTypes, origin)
	}

	/** 
	 * Register that a message has been sent to this type variable.
	 */
	def messageSend(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		val it = new MessageSend(selector, arguments, returnType)
		if (typeInfo === null) {
			if (isClosureMessage)	setTypeInfo(new ClosureTypeInfo(arguments.map[it as ITypeVariable], returnType))
			else					setTypeInfo(new SimpleTypeInfo())
		} 
		typeInfo.messages.add(it)
	}

	/**
	 * A sealed variable can not be further restricted.
	 */
	def isSealed() { typeInfo !== null && typeInfo.sealed }

	def beSealed() { typeInfo.beSealed() }

	// ************************************************************************
	// ** Unification information
	// ************************************************************************
	def unifiedWith(TypeVariable other) {
		typeInfo !== null && typeInfo == other.typeInfo
	}

	def isCanonical() {
		typeInfo.canonicalUser == this
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	override toString() '''t(«owner.debugInfo»)'''

	def description(boolean full) '''
		Type information for «owner.debugInfoInContext» {
			subtypes: «subtypes.map[owner.debugInfoInContext]»,
			supertypes: «supertypes.map[owner.debugInfoInContext]»,
			«IF typeInfo === null»
				no type information
			«ELSEIF canonical || full»
				«typeInfo.fullDescription»
			«ELSE»
				... unified with «typeInfo.canonicalUser.owner.debugInfoInContext»
			«ENDIF»
		}
	'''

	def descriptionForReport() { description(false) }
	def fullDescription() { description(true) }

	def allSupertypes() {
		newHashSet => [ result |
			typeInfo.users.forEach [ unified |
				unified.supertypes.forEach [ supertype |
					if (!this.unifiedWith(supertype)) result.add(supertype)
				]
			]
		]
	}
}
