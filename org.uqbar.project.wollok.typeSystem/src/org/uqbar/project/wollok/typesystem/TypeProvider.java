package org.uqbar.project.wollok.typesystem;

import org.eclipse.emf.ecore.EObject;
import org.uqbar.project.wollok.typesystem.NamedObjectWollokType;

/**
 * I can search for types in a program, parsing them out of a string.
 *
 * @author npasserini
 */
public interface TypeProvider {

	public ClassBasedWollokType classType(EObject context, String classFQN);
	public GenericType genericType(EObject context, String classFQN, String... typeParameterNames);
	public GenericType closureType(EObject context, int parameterCount);
	public NamedObjectWollokType objectType(EObject context, String classFQN);

}
