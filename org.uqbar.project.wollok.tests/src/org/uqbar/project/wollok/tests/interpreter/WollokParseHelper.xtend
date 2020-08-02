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
 * @author dodain   ==> parse(CharSequence, ResourceSet) modified for issue #1815 (.wlk / .wtest / .wpgm same file name)
 *
 */
class WollokParseHelper extends ParseHelper<WFile>{
	
	/**
	 * file is a pair fileName => content
	 */
	def WFile parse(Pair<String,String> file, ResourceSet resourceSetToUse) throws Exception {
		parse(file, resourceSetToUse, false)
	}

	override parse(CharSequence text, ResourceSet resourceSetToUse) throws Exception {
		text.toString.computeFileExtension
		val uri = computeUnusedUri(resourceSetToUse).trimFileExtension.appendFileExtension(fileExtension)
		return super.parse(getAsStream(text), uri, null, resourceSetToUse)
	}
	
	def void computeFileExtension(String fileContent) {
		this.fileExtension = 
			if (fileContent.toString.contains("program "))
				WollokConstants.PROGRAM_EXTENSION
			else if (fileContent.toString.contains("test "))
				WollokConstants.TEST_EXTENSION
			else
				WollokConstants.WOLLOK_DEFINITION_EXTENSION
	}
	
	def WFile parse(Pair<String,String> file, ResourceSet resourceSetToUse, boolean createFilesOnDisk) throws Exception {
		file.value.computeFileExtension
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