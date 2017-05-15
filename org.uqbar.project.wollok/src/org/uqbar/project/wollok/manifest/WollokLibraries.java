package org.uqbar.project.wollok.manifest;

import java.util.List;

import org.eclipse.emf.ecore.resource.Resource;

public interface WollokLibraries {
	public List<WollokLib> getWollokLibs(Resource resource);
}
