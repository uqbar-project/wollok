package org.uqbar.project.wollok.typesystem.constraints.variables

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * I represent a variable associated to some type of schema containing type parameters. 
 * I can be simple, as {@code E} in {@code List<E>} (single class type parameter),
 * compound, as `(E) => Boolean` as the paramter of List.find,
 * or a self type, as the return type of List.filter (which is also compound).
 * 
 * In the current state of the art, parametric types (and hence, type parameters) are only introduced by type annotations,
 * but they can be progagated to other parts of the code that use objects with parametric types.
 * Blocks have also parametric types, but they are handled by normal type variables and a special type info ({@link ClosureTypeInfo}).
 * 
 * I am a proxy for a real type variable, which will be computed on each use. 
 */
abstract class TypeVariableSchema extends ITypeVariable {
	@Accessors
	extension TypeVariablesRegistry registry
	var instanceCount = 0
	
	new(TypeVariableOwner owner) {
		super(owner)
	}
	
	def TypeVariable tvar(EObject obj) { 
		registry.tvar(obj)
	}

	def dispatch beSubtypeOf(ITypeVariable variable) {
		throw new UnsupportedOperationException("Yet not implemented")		
	}

	def dispatch beSupertypeOf(ITypeVariable variable) {
		throw new UnsupportedOperationException("Yet not implemented")		
	}
	
	def createCompoundOwner() {
		new ParameterTypeVariableOwner(owner, '''$« instanceCount += 1 »''')
	}
}
