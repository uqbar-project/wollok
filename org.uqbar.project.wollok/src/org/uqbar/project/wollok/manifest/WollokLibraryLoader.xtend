package org.uqbar.project.wollok.manifest

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription

interface WollokLibraryLoader {
	
	def Iterable<IEObjectDescription> load(Resource context)
}
