package org.uqbar.project.wollok.typesystem;

import java.util.Set;

import org.eclipse.emf.ecore.EObject;

/**
 * I can search for types in a program, parsing them out of a string.
 *
 * @author npasserini
 */
public interface TypeProvider {

	public ClassInstanceType classType(EObject context, String classFQN);
	public GenericType genericType(EObject context, String classFQN, String... typeParameterNames);
	public GenericType closureType(EObject context, int parameterCount);
	public NamedObjectType objectType(EObject context, String classFQN);
	public Set<TypeFactory> getAllTypes();

}
