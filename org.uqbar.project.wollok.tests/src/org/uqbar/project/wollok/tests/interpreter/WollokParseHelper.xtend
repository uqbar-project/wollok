package org.uqbar.project.wollok.tests.interpreter

import java.io.File
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.testing.util.ParseHelper
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * 
 * @author tesonep
 */
class WollokParseHelper extends ParseHelper<WFile>{
	
	/**
	 * file is a pair fileName => content
	 */
	def WFile parse(Pair<String,String> file, ResourceSet resourceSetToUse) throws Exception {
		parse(file, resourceSetToUse, false)
	}

	def WFile parse(Pair<String,String> file, ResourceSet resourceSetToUse, boolean createFilesOnDisk) throws Exception {
		this.fileExtension = if (file.value.toString.contains("program "))
									WollokConstants.PROGRAM_EXTENSION
							 else if (file.value.toString.contains("test "))
									WollokConstants.TEST_EXTENSION
							else
									WollokConstants.CLASS_OBJECTS_EXTENSION
		val uri = resourceSetToUse.calculateUriFor(file).trimFileExtension.appendFileExtension(fileExtension)
		
		if (createFilesOnDisk) {
			val f = new File(uri.toFileString)
			
			if (!f.exists) {
				f.parentFile.mkdirs
				f.createNewFile
			}
		}
		
		val p = parse(getAsStream(file.value), uri, null, resourceSetToUse)
		p.eResource.URI = uri
		if (p === null)
			throw new RuntimeException("Error while parsing program with resourceSet = " + resourceSetToUse.resources + " the following program: " + file.value)
		return p
	}
	
	def calculateUriFor(ResourceSet resourceSetToUse, Pair<String,String> file) {
		if (file.key === null)
			computeUnusedUri(resourceSetToUse)
		else
			URI.createURI("target/test-files/" + file.key + "." + fileExtension);
	}
}