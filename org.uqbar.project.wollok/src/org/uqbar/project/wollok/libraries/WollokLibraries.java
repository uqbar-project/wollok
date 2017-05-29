package org.uqbar.project.wollok.libraries;

import org.eclipse.emf.ecore.resource.Resource;

/**
 * It finds all external libraries related to a wollok file 
 * represented by resource
 * @author leo
 */
public interface WollokLibraries {
	public Iterable<WollokLib> getWollokLibs(Resource resource);
}
