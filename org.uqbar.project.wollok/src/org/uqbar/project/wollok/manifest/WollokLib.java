package org.uqbar.project.wollok.manifest;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.IEObjectDescription;
import org.eclipse.xtext.resource.IResourceDescription;

/**
 * 
 * @author leo
 */
public interface WollokLib {
	
	//public WollokManifest getManifest();
	
	public Iterable<IEObjectDescription> load(Resource resource, IResourceDescription.Manager manager);
}
