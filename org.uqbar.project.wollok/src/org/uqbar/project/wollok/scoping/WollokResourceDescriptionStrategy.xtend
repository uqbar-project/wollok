package org.uqbar.project.wollok.scoping

import com.google.inject.Singleton
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.util.IAcceptor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WPackage
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.IReferenceDescription

/**
 * Customizes the strategy in order to avoid exporting all "named" objects
 * to other files.
 * In wollok "exportable" objects are only packages, named objects and classes.
 * You cannot export variables or any WExpression
 * 
 * @author jfernandes
 */
@Singleton
class WollokResourceDescriptionStrategy extends DefaultResourceDescriptionStrategy {
	
	override createEObjectDescriptions(EObject eObject, IAcceptor<IEObjectDescription> acceptor) {
		if (eObject instanceof WFile)
			super.createEObjectDescriptions(eObject, acceptor)
		else if (eObject instanceof WPackage)
			super.createEObjectDescriptions(eObject, acceptor)
		else if (eObject instanceof WMethodContainer) {
			super.createEObjectDescriptions(eObject, acceptor)
			false
		}
		else
			false
	}

	override createReferenceDescriptions(EObject from, URI exportedContainerURI, IAcceptor<IReferenceDescription> acceptor) {
		try {
			return super.createReferenceDescriptions(from, exportedContainerURI, acceptor)
		} catch (Exception e) {
			e.printStackTrace
			println(e)
			println(from)
			println("URI: " + exportedContainerURI)
			return true
		} 
	}
	
}