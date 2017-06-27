package org.uqbar.project.wollok.typesystem;

import org.eclipse.emf.ecore.EObject;

/**
 * I can search for types in a program, parsing them out of a string.
 *
 * @author npasserini
 */
public interface TypeProvider {

	public abstract ClassBasedWollokType classType(EObject context, String classFQN);
	public abstract NamedObjectWollokType objectType(EObject context, String classFQN);

}
