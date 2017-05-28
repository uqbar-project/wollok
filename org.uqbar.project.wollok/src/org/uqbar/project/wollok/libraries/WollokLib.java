package org.uqbar.project.wollok.libraries;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;

/**
 * It represents a wollok library. 
 * A Wollok library is able to add objects and classes to a wollok project
 * @author leo
 */
public interface WollokLib {
	
	/** Load all objetcts in order to resolve resuorce wollok file"*/
	public Iterable<IEObjectDescription> load(Resource resource);

}
