package org.uqbar.project.wollok.semantics

import it.xsemantics.runtime.RuleEnvironment
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.project.wollok.wollokDsl.WParameter

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * 
 * @author jfernandes
 */
class ObjectLiteralWollokType extends BasicType implements ConcreteType {
	WObjectLiteral object
	WollokDslTypeSystem system
	RuleEnvironment env
	
	new(WObjectLiteral obj, WollokDslTypeSystem system, RuleEnvironment env) {
		super("<object>")
		object = obj
		this.system = system
		this.env = env
	}
	
	override getName() { '{ ' + object.methods.map[name].join(' ; ') + ' }'	}
	
	def signature(WMethodDeclaration m) {
		m.name + parametersSignature(m) + returnTypeSignature(m)
	}
	
	def parametersSignature(WMethodDeclaration m) {
		if (m.parameters.empty) 
			"" 
		else 
			"(" + m.parameters.map[type.name].join(", ") + ')'
	}
	
	def returnTypeSignature(WMethodDeclaration m) {
		val rType = system.queryTypeFor(env, m)
		if (rType.failed || rType.first == WollokType.WVoid)
			''
		else
		 	' : ' + rType.first
	}
	
	override understandsMessage(MessageType message) {
		lookupMethod(message) != null
	}
	
	override lookupMethod(MessageType message) {
		val m = object.lookupMethod(message.name, message.parameterTypes)
		// TODO: por ahora solo checkea misma cantidad de parametros
		// 		debería en realidad checkear tipos !  
		if (m != null)
			m
		else
			null
	}
	
	override resolveReturnType(MessageType message, WollokDslTypeSystem system, RuleEnvironment g) {
		val method = lookupMethod(message)
		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir
		system.env(g, method, WollokType)
	}
	
	override getAllMessages() { object.methods.map[messageType.first] }
	
	override refine(WollokType previous, RuleEnvironment g) {
		//TODO deberia usar el G !
		val intersectMessages = allMessages.filter[previous.understandsMessage(it)]
		new StructuralType(intersectMessages.iterator)
	}
	
	def messageType(WMethodDeclaration m) { system.queryMessageTypeForMethod(env, m) }
	def type(WParameter p) { system.queryTypeFor(env, p).first }
	
}