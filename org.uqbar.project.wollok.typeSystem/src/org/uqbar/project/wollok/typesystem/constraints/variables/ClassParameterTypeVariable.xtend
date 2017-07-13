package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

/**
 * I represent a type parameter that is bound to a class, for example I am the {@code E} in {@code List<E>}.
 * I am a class type parameter, please note that there is currently no support for method type parameters in Wollok type system.
 * 
 * In the current state of the art, parametric types (and hence, type parameters) are only introduced by type annotations
 * (and more specifically: the Collection hierarchy).
 * But they can be progagated to other parts of the code that use objects with parametric types.
 * Blocks have also parametric types, but they are handled by normal type variables and a special type info ({@link ClosureTypeInfo}).
 * 
 * I am a proxy for a real type variable, which will be computed on each use. 
 * 
 * Since I am related to a class, current usage expects to be related to a message send, and the real type variable will be obtained
 * from the receiver of the message.
 */
class ClassParameterTypeVariable implements ITypeVariable {
	@Accessors
	EObject owner
	
	@Accessors
	extension TypeVariablesRegistry registry

	String paramName

	new(EObject owner, String paramName) {
		this.owner = owner
		this.paramName = paramName
	}

	/**
	 * I can have supertypes when I am used as return type for a method. 
	 * The received type variable should be a a message send 
	 * (i.e. {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}
	 */
	override beSubtypeOf(TypeVariable variable) {
		variable.owner.classTypeParameter.beSubtypeOf(variable)
	}

	/**
	 * I can have subtypes when I am used as parameter type for a method. 
	 * The received type variable should be being used as a parametr to a message send, i.e.
	 * its container should be a message send, 
	 * such as {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}.
	 */
	override beSupertypeOf(TypeVariable variable) {
		variable.owner.eContainer.classTypeParameter.beSupertypeOf(variable)
	}


	def dispatch classTypeParameter(EObject unknownObject) {
		throw new TypeSystemException('''Extracting a class type parameter from a «unknownObject.class» is not possible or yet not implemented''')
	}

	def dispatch classTypeParameter(WMemberFeatureCall messageSend) {
		val receiverTypeInfo = messageSend.memberCallTarget.tvar.typeInfo as GenericTypeInfo
		receiverTypeInfo.param(paramName)
	}

}
