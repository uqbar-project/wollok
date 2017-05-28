package org.uqbar.project.wollok.libraries

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.resource.IEObjectDescription

/**
 * An instance of this class is able to add objects and classes to a wollok file represented by context
 * @author leo
 */
interface WollokLibraryLoader {
	
	def Iterable<IEObjectDescription> load(Resource context)
}
