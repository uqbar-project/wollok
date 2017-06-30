package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo

interface ITypeVariable {
	def EObject getOwner()
	
	def void beSubtypeOf(TypeVariable variable)
	
	def void beSupertypeOf(TypeVariable variable)
}

class TypeVariable implements ITypeVariable {
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

	new(EObject owner) {
		this.owner = owner
	}

	def static simple(EObject owner) {
		new TypeVariable(owner)
	}
	
	def static newVoid(EObject owner) {
		new TypeVariable(owner) => [ setTypeInfo(new VoidTypeInfo()) ]
	}

	def static closure(EObject owner, List<TypeVariable> parameters, TypeVariable returnType) {
		new TypeVariable(owner) => [ setTypeInfo(new ClosureTypeInfo(parameters, returnType)) ]
	}

	def static generic(EObject owner, List<String> typeParameterNames) {
		new TypeVariable(owner) => [ setTypeInfo(new GenericTypeInfo(typeParameterNames.toInvertedMap[synthetic])) ]
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
		typeInfo.getType(this)
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
		typeInfo != null && typeInfo.hasErrors
	}

	def reportErrors(ConfigurableDslValidator validator) {
		typeInfo?.reportErrors(this, validator)
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
		if (typeInfo != null) typeInfo.subtypeAdded()
	}

	/**
	 * Internal method, do not call directly, use {@link #beSupertypeOf(TypeVariable)} instead.
	 */
	protected def addSupertype(TypeVariable supertype) {
		this.supertypes.add(supertype)
		if (typeInfo != null) typeInfo.supertypeAdded()
	}
	
	def beVoid() {
		if (typeInfo == null) setTypeInfo(new VoidTypeInfo())
		else typeInfo.beVoid
	}

	// ************************************************************************
	// ** Adding / accessing type info
	// ************************************************************************
	def setTypeInfo(TypeInfo newTypeInfo) {
		newTypeInfo.addUser(this)
		this.typeInfo = newTypeInfo
	}

	/**
	 * Adds a minType to this variable. This is only possible for simple types. 
	 * Therefore, if type info has not yet been assigned, it will be forced to a simple type. 
	 * If the variable points to a closure type this will produce a type error.
	 */
	def addMinimalType(WollokType type) {
		if (typeInfo == null) setTypeInfo(new SimpleTypeInfo()) 
		typeInfo.addMinimalType(type)
	}

	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		if (typeInfo == null) setTypeInfo(new SimpleTypeInfo()) 
		typeInfo.maximalConcreteTypes = maxTypes
	}
	
	/** 
	 * Register that a message has been sent to this type variable.
	 */
	def messageSend(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		// TODO Currently only simple types are supporting message sending, but closures also should.
		if (typeInfo == null) setTypeInfo(new SimpleTypeInfo()) 
		typeInfo.messages.add(new MessageSend(selector, arguments, returnType))
	}

	/**
	 * A sealed variable can not be further restricted.
	 */
	def isSealed() { typeInfo != null && typeInfo.sealed }

	def beSealed() { typeInfo.beSealed() }

	// ************************************************************************
	// ** Unification information
	// ************************************************************************
	def unifiedWith(TypeVariable other) {
		this.typeInfo == other.typeInfo
	}

	def isCanonical() {
		typeInfo.canonicalUser == this
	}

	// ************************************************************************
	// ** Debugging
	// ************************************************************************
	override toString() '''t(«owner.debugInfo»)'''

	def fullDescription() '''
		«class.simpleName» {
			owner: «owner.debugInfo»,
			subtypes: «subtypes.map[owner.debugInfo]»,
			supertypes: «supertypes.map[owner.debugInfo]»,
			«IF typeInfo == null»
				no type information
			«ELSEIF canonical»
				«typeInfo.fullDescription»
			«ELSE»
				... unified with «typeInfo.canonicalUser»
			«ENDIF»
		}
	'''

	def allSupertypes() {
		newHashSet => [ result |
			typeInfo.users.forEach [ unified |
				unified.supertypes.forEach [ supertype |
					if (!this.unifiedWith(supertype)) result.add(supertype)
				]
			]
		]
	}

	def allSubtypes() {
		newHashSet => [ result |
			typeInfo.users.forEach [ unified |
				unified.subtypes.forEach [ subtype |
					if (!this.unifiedWith(subtype)) result.add(subtype)
				]
			]
		]
	}
}
