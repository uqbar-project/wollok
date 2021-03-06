package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.typesystem.constraints.variables.VoidTypeInfo.*

class TypeVariable extends ITypeVariable {
	val Logger log = Logger.getLogger(class)

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
	
	@Accessors
	val Set<TypeVariable> messageParameters = newHashSet

	@Accessors
	List<TypeSystemException> errors = newArrayList

	// ************************************************************************
	// ** Construction
	// ************************************************************************
	
	new(EObject programElement) {
		this(new ProgramElementTypeVariableOwner(programElement))
	}

	new(TypeVariableOwner owner) {
		super(owner)
	}


	def static simple(TypeVariableOwner owner) {
		new TypeVariable(owner)
	}

	def static newVoid(TypeVariableOwner owner) {
		new TypeVariable(owner) => [setTypeInfo(new VoidTypeInfo())]
	}

	def static classTypeParameter(TypeVariableOwner owner, GenericType type, String paramName) {
		new ClassTypeParameterVariable(owner, type, paramName)
	}

	def static methodTypeParameter(TypeVariableOwner owner, GenericType type, String methodName, String paramName) {
		new MethodTypeParameterVariable(owner, type, methodName, paramName)
	}

	/**
	 * I can not be instantiated, I am already a concrete type variable.
	 */
	override instanceFor(ConcreteType concreteReceiver, MessageSend _unused_) { this }

	// ************************************************************************
	// ** For the TypeSystem implementation
	// ************************************************************************
	override getType() {
		if(typeInfo !== null) typeInfo.getType(this) else WollokType.WAny
	}

	// ************************************************************************
	// ** Errors
	// ************************************************************************

	def boolean hasErrors() {
		return owner.hasErrors
	}
	
	def hasErrors(WollokType type) {
		return errors.exists [ relatedToType(type) ]
	}

	def addError(TypeSystemException exception) {
		owner.addError(exception)
		log.info('''«exception.message» ==> reported in «fullDescription»''')
	}

	// REVIEW Is it necessary to pass 'user'?
	def reportErrors(ConfigurableDslValidator validator) {
		owner.reportErrors(validator)
	}

	/** 
	 * The EObject we have (owner) can be obsolete, most likely because it belongs to 
	 * an old build. The Resource can get us the right EObject, i.e. one with the same URI
	 */
	def ownerIn(Resource resource) {
		resource.getEObject(owner.errorReportTarget.eResource.getURIFragment(owner.errorReportTarget))
	}

	// ************************************************************************
	// ** Adding constraints
	// ************************************************************************
	def dispatch beSupertypeOf(ITypeVariable subtype) {
		subtype.beSubtypeOf(this)
	}

	def dispatch beSupertypeOf(TypeVariable subtype) {
		this.addSubtype(subtype)
		subtype.addSupertype(this)
	}
	
	def addMessageParameter(TypeVariable param) {
		messageParameters.add(param)
	}

	def dispatch beSubtypeOf(ITypeVariable supertype) {
		supertype.beSupertypeOf(this)
	}

	def dispatch beSubtypeOf(TypeVariable supertype) {
		this.addSupertype(supertype)
		supertype.addSubtype(this)
	}

	/**
	 * Internal method, do not call directly, use {@link #beSupertypeOf(TypeVariable)} instead.
	 */
	def addSubtype(TypeVariable subtype) {
		this.subtypes.add(subtype)
		if(typeInfo !== null) typeInfo.subtypeAdded(subtype)
	}

	/**
	 * Internal method, do not call directly, use {@link #beSupertypeOf(TypeVariable)} instead.
	 */
	def addSupertype(TypeVariable supertype) {
		this.supertypes.add(supertype)
		if(typeInfo !== null) typeInfo.supertypeAdded(supertype)
	}

	def beVoid() { setTypeInfo(new VoidTypeInfo()) }
	def beNonVoid() { setTypeInfo(new GenericTypeInfo()) }

	override instanceFor(TypeVariable variable) {
		this // I have nothing to be instantiated
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
		} else if (typeInfo === null) {
			owner.checkCanBeVoid()
			doSetTypeInfo(newTypeInfo)
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
		if(typeInfo === null) setTypeInfo(new GenericTypeInfo())
		typeInfo.addMinType(type, this)
	}

	def boolean setMaximalConcreteTypes(MaximalConcreteTypes maxTypes, TypeVariable offender) {
		if(typeInfo === null) setTypeInfo(new GenericTypeInfo())
		typeInfo.setMaximalConcreteTypes(maxTypes, offender)
	}

	/** 
	 * Register that a message has been sent to this type variable.
	 */
	def messageSend(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		val message = new MessageSend(this, selector, arguments, returnType)

		if(typeInfo === null) setTypeInfo(new GenericTypeInfo())
		typeInfo.messages.add(message)
	}

	/**
	 * A sealed variable can not be further restricted.
	 */
	def isSealed() { typeInfo !== null && typeInfo.sealed }

	def beSealed() { typeInfo.beSealed }

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
	override toString() '''t(«owner.debugInfoInContext»)'''

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
					if(!this.unifiedWith(supertype)) result.add(supertype)
				]
			]
		]
	}	
}
