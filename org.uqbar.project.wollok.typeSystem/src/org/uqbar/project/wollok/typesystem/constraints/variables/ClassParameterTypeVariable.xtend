package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WArgumentList
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WMemberFeatureCall
import org.uqbar.project.wollok.wollokDsl.WSuperInvocation

/**
 * I represent a type parameter that is bound to a class, for example I am the {@code E} in {@code List<E>}.
 * I am a class type parameter, please note that there is currently no support for method type parameters in Wollok type system.
 * 
 * In the current state of the art, parametric types (and hence, type parameters) are only introduced by type annotations,
 * But they can be progagated to other parts of the code that use objects with parametric types.
 * Blocks have also parametric types, but they are handled by normal type variables and a special type info ({@link ClosureTypeInfo}).
 * 
 * I am a proxy for a real type variable, which will be computed on each use. 
 * 
 * Since I am related to a class, current usage expects to be related to a message send, and the real type variable will be obtained
 * from the receiver of the message.
 */
class ClassParameterTypeVariable extends TypeVariableSchema {
	@Accessors
	GenericType genericType
	
	String paramName

	new(TypeVariableOwner owner, GenericType genericType, String paramName) {
		super(owner)
		this.genericType = genericType
		this.paramName = paramName
	}

 	override getType() {
		WollokType.WAny
	}
	
	/**
	 * I can have supertypes when I am used as return type for a method. 
	 * The received type variable should be a a message send 
	 * (i.e. {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}
	 */
	def dispatch beSubtypeOf(TypeVariable variable) {
		variable.owner.classTypeParameter.beSubtypeOf(variable)		
	}

	/**
	 * I can have subtypes when I am used as parameter type for a method. 
	 * The received type variable should be being used as a parameter to a message send, i.e.
	 * its container should be a message send, 
	 * such as {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}.
	 */
	def dispatch beSupertypeOf(TypeVariable variable) {
		instanceFor(variable).beSupertypeOf(variable)
	}

	override instanceFor(TypeVariable variable) {
		variable.owner.classTypeParameter as TypeVariable
	}
	
	override instanceFor(ConcreteType concreteReceiver) {
		(concreteReceiver as GenericTypeInstance).param(paramName)
	}
	
	def dispatch ITypeVariable classTypeParameter(ProgramElementTypeVariableOwner owner) {
		// TODO We are ignoring here other possible type variable owners, so this will be a problem soon.
		owner.programElement.classTypeParameter
	}

	def dispatch ITypeVariable classTypeParameter(EObject unknownObject) {
		throw new TypeSystemException(NLS.bind(Messages.RuntimeTypeSystemException_EXTRACTING_TYPE_CLASS_NOT_IMPLEMENTED, unknownObject.class))
	}

	def dispatch ITypeVariable classTypeParameter(WArgumentList arg) {
		arg.eContainer.classTypeParameter
	}

	def dispatch ITypeVariable classTypeParameter(WConstructorCall constructorCall) {
		classTypeParameterFor(constructorCall.tvar.typeInfo)
	}

	def dispatch ITypeVariable classTypeParameter(WMemberFeatureCall messageSend) {
		var tvar = classTypeParameterFor(messageSend.memberCallTarget.tvar.typeInfo)
		if (tvar instanceof TypeVariable) tvar else classTypeParameter(messageSend.memberCallTarget)
	}

	def dispatch classTypeParameterFor(TypeInfo typeInfo) {
		throw new UnsupportedOperationException 
	}

	def dispatch classTypeParameterFor(GenericTypeInfo typeInfo) {
		typeInfo.param(genericType, paramName)
	}
		
	override toString() '''t(«owner.debugInfo»: «genericType».«paramName»)'''
	}
