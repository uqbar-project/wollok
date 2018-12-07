package org.uqbar.project.wollok.typesystem

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.typesystem.constraints.variables.TypeVariable
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author jfernandes
 * @author npasserini
 */
abstract class AbstractContainerWollokType extends BasicType implements ConcreteType, TypeFactory {
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
  		// TODO: Revisar por ahora solo checkea misma cantidad de parametros
  		// tal vez debería en realidad checkear tipos.  		
  		container.lookupMethod(selector, parameterTypes, true)		
  	}		
  			
  	override resolveReturnType(MessageType message) {		
  		val method = lookupMethod(message)		
  		//	TODO: si no está, debería ir al archivo del método (podría estar en otro archivo) e inferir		
  		typeSystem.type(method)		
  	}
  	
  	override getAllMessages() {		
 		container.allUntypedMethods.map[m| typeSystem.queryMessageTypeForMethod(m)]		
 	}
 
 	override ConcreteType instanceFor(TypeVariable parent) { this }
 	
 	override equals(Object obj) {
 		obj instanceof AbstractContainerWollokType && (obj as AbstractContainerWollokType).container.URI == container.URI		
 	}		
 			
 	override hashCode() { container.hashCode }
	
}