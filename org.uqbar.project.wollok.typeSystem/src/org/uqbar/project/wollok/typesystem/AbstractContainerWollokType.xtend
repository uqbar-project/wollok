package org.uqbar.project.wollok.typesystem

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

/**
 * 
 * @author jfernandes
 * @author npasserini
 */
abstract class AbstractContainerWollokType extends BasicType implements ConcreteType {
	@Accessors(PUBLIC_GETTER)
	WMethodContainer container
	
	@Accessors(PUBLIC_GETTER)
	protected TypeSystem typeSystem
	
	new(WMethodContainer container, TypeSystem ts) {
		super(container.name)
		this.container = container
		this.typeSystem = ts
	}
		
	override understandsMessage(MessageType message) {
 		lookupMethod(message) !== null		
 	}
 	
 	override lookupMethod(MessageType message) {
 		this.lookupMethod(message.name, message.parameterTypes)
 	}

 	override lookupMethod(String selector, List<?> parameterTypes) {		
  		val m = container.lookupMethod(selector, parameterTypes, true)		
  		// TODO: por ahora solo checkea misma cantidad de parametros		
  		// 		debería en realidad checkear tipos !  		
  		if (m !== null && m.parameters.size == parameterTypes.size)		
  			m		
  		else		
  			null		
  	}		
  			
  	override resolveReturnType(MessageType message) {		
  		val method = lookupMethod(message)		
  		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir		
  		typeSystem.type(method)		
  	}
  	
  	override getAllMessages() {		
 		container.allMethods.map[m| typeSystem.queryMessageTypeForMethod(m)]		
 	}
 	
 	override equals(Object obj) {
 		obj instanceof AbstractContainerWollokType && (obj as AbstractContainerWollokType).container.URI == container.URI		
 	}		
 			
 	override hashCode() { container.hashCode }
	
}