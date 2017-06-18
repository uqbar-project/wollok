package org.uqbar.project.wollok.typesystem.constraints.variables

import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.validation.ConfigurableDslValidator

import static extension org.uqbar.project.wollok.typesystem.constraints.WollokModelPrintForDebug.debugInfo
import static extension org.uqbar.project.wollok.typesystem.constraints.variables.WollokTypeSystemPrettyPrinter.*

class TypeVariable {
	@Accessors
	val EObject owner

	@Accessors
	var TypeInfo typeInfo

	@Accessors
	val Set<TypeVariable> subtypes = newHashSet

	@Accessors
	val Set<TypeVariable> supertypes = newHashSet

	new(EObject owner, TypeInfo typeInfo) {
		this.owner = owner
		this.typeInfo = typeInfo => [ addUser(this) ]
	}

	def static simple(EObject object) {
		new TypeVariable(object, new SimpleTypeInfo())
	}

	def static closure(EObject object, List<TypeVariable> parameters, TypeVariable returnType) {
		new TypeVariable(object, new ClosureTypeInfo(parameters, returnType))
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
	def hasErrors() {
		typeInfo.hasErrors
	}

	def reportErrors(ConfigurableDslValidator validator) {
		if (hasErrors)
			validator.report('''expected <<«expectedType»>> but found <<«foundType»>>''', owner)
	}

	// ************************************************************************
	// ** Adding constraints
	// ************************************************************************
	def beSupertypeOf(TypeVariable subtype) {
		this.subtypes.add(subtype)
		subtype.supertypes.add(this)
	}

	def beSubtypeOf(TypeVariable supertype) {
		this.supertypes.add(supertype)
		supertype.subtypes.add(this)
	}

	// ************************************************************************
	// ** Adding / accessing type info
	// ************************************************************************
	def setTypeInfo(TypeInfo newTypeInfo) {
		newTypeInfo.addUser(this)
		this.typeInfo = newTypeInfo
	}

	def getMinimalConcreteTypes() { typeInfo.minimalConcreteTypes }

	def addMinimalType(WollokType type) { typeInfo.addMinimalType(type) }

	def getMaximalConcreteTypes() { typeInfo.maximalConcreteTypes }

	def setMaximalConcreteTypes(MaximalConcreteTypes maxTypes) {
		typeInfo.maximalConcreteTypes = maxTypes
	}
	
	def messageSend(String selector, List<TypeVariable> arguments, TypeVariable returnType) {
		typeInfo.messages.add(new MessageSend(selector, arguments, returnType))
	}

	def isSealed() { typeInfo.sealed }

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
	override def toString() '''t(«owner.debugInfo»)'''

	def fullDescription() '''
		«class.simpleName» {
			owner: «owner.debugInfo»,
			subtypes: «subtypes.map[owner.debugInfo]»,
			supertypes: «supertypes.map[owner.debugInfo]»,
			«IF canonical»
				sealed: «sealed»,
				minTypes: «minimalConcreteTypes»,
				maxTypes: «maximalConcreteTypes?:"unknown"»
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
