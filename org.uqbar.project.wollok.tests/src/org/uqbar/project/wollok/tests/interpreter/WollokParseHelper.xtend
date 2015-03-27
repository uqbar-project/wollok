package org.uqbar.project.wollok.tests.interpreter

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.junit4.util.ParseHelper
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.WollokConstants

class WollokParseHelper extends ParseHelper<WFile>{
	override WFile parse(CharSequence text, ResourceSet resourceSetToUse) throws Exception {
		if(text.toString.contains("program ")){
			this.fileExtension = WollokConstants.PROGRAM_EXTENSION
		}else{
			if(text.toString.contains("test ")){
				this.fileExtension = WollokConstants.TEST_EXTENSION
			}else{
				this.fileExtension = WollokConstants.CLASS_OBJECTS_EXTENSION
			}
		}
		
		return parse(getAsStream(text), computeUnusedUri(resourceSetToUse), null, resourceSetToUse);
	}
}