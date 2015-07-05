package org.uqbar.project.wollok.tests.interpreter

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.junit4.util.ParseHelper
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.WollokConstants
import org.eclipse.emf.common.util.URI

/**
 * 
 * @author tesonep
 */
class WollokParseHelper extends ParseHelper<WFile>{
	/**
	 * file is a pair fileName -> content
	 */
	def WFile parse(Pair<String,String> file, ResourceSet resourceSetToUse) throws Exception {
		this.fileExtension = if (file.value.toString.contains("program "))
									WollokConstants.PROGRAM_EXTENSION
							 else if (file.value.toString.contains("test "))
									WollokConstants.TEST_EXTENSION
							else
									WollokConstants.CLASS_OBJECTS_EXTENSION
		
		val p = parse(getAsStream(file.value), resourceSetToUse.calculateUriFor(file), null, resourceSetToUse)
		if (p == null)
			throw new RuntimeException("Error while parsing program with resourceSet = " + resourceSetToUse.resources + " the following program: " + file.value)
		return p
	}
	
	def calculateUriFor(ResourceSet resourceSetToUse, Pair<String,String> file) {
		if (file.key == null)
			computeUnusedUri(resourceSetToUse)
		else
			URI.createURI(file.key + "." + fileExtension);
	}
}