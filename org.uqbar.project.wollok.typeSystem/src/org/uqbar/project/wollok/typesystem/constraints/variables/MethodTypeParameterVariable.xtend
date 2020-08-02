package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.typesystem.ConcreteType
import org.uqbar.project.wollok.typesystem.GenericType
import org.uqbar.project.wollok.typesystem.Messages
import org.uqbar.project.wollok.typesystem.TypeSystemException
import org.uqbar.project.wollok.typesystem.WollokType
import org.uqbar.project.wollok.wollokDsl.WBinaryOperation
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
class MethodTypeParameterVariable extends TypeVariableSchema {
	GenericType type
	String methodName
	String paramName

	new(TypeVariableOwner owner, GenericType type, String methodName, String paramName) {
		super(owner)
		this.type = type
		this.methodName = methodName
		this.paramName = paramName
	}

 	override getType() { WollokType.WAny }
	
	/**
	 * I can have supertypes when I am used as return type for a method. 
	 * The received type variable should be a a message send 
	 * (i.e. {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}
	 */
	def beSubtypeOf(TypeVariable variable) {
		instanceFor(variable).beSubtypeOf(variable)		
	}

	/**
	 * I can have subtypes when I am used as parameter type for a method. 
	 * The received type variable should be being used as a parameter to a message send, i.e.
	 * its container should be a message send, 
	 * such as {@link WMemberFeatureCall}, {@link WBinaryOperation} or {@link WSuperInvocation}.
	 */
	def beSupertypeOf(TypeVariable variable) {
		instanceFor(variable).beSupertypeOf(variable)
	}

	// ************************************************************************
	// ** Instantiation (i.e. look for a related tvar, the actual tvar)
	// ************************************************************************

	override instanceFor(TypeVariable variable) {
		variable.owner.typeParameter as TypeVariable
	}
	
	override instanceFor(ConcreteType concreteReceiver, MessageSend messageSend) {
		// TODO Tal vez necesitamos un nuevo tipo de owner asociado al messageSend. 
		// Por ahora lo asocié a lo más parecido que tenemos que es el owner del return type del message send.
		// (Se parece porque el owner del return type es sintácticamente la expresión entera (message send).
		messageSend.param(paramName, [| 
			registry.newParameter(messageSend.returnType.owner, paramName)
		])
	}

	/**
	 * Given that this type parameter is associated to a program element, we can relate it to an actual 
	 * type variable. This method and the following contain the algorithm for looking for that TVar.
	 */
	def dispatch ITypeVariable typeParameter(ProgramElementTypeVariableOwner owner) {
		// TODO We are ignoring here other possible type variable owners, so this will be a problem soon.
		owner.programElement.typeParameter
	}

	def dispatch ITypeVariable typeParameter(EObject unknownObject) {
		throw new TypeSystemException(NLS.bind(Messages.RuntimeTypeSystemException_EXTRACTING_TYPE_CLASS_NOT_IMPLEMENTED, unknownObject.class))
	}

	override toString() '''t(«owner.debugInfo»: method type parameter «paramName»)'''
}
