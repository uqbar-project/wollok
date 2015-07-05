package org.uqbar.project.wollok.tests.interpreter

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.junit4.util.ParseHelper
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.WollokConstants

class WollokParseHelper extends ParseHelper<WFile>{
	override WFile parse(CharSequence text, ResourceSet resourceSetToUse) throws Exception {
		this.fileExtension = if (text.toString.contains("program "))
									WollokConstants.PROGRAM_EXTENSION
							 else if (text.toString.contains("test "))
									WollokConstants.TEST_EXTENSION
							else
									WollokConstants.CLASS_OBJECTS_EXTENSION
		
		val p = parse(getAsStream(text), computeUnusedUri(resourceSetToUse), null, resourceSetToUse)
		if (p == null)
			throw new RuntimeException("Error while parsing program with resourceSet = " + resourceSetToUse.resources + " the following program: " + text)
		return p;
	}
}