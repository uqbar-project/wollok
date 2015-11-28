package org.uqbar.project.wollok.tests.interpreter

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.junit4.util.ParseHelper
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.WollokConstants
import org.eclipse.emf.common.util.URI
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*
import java.io.File
import org.eclipse.core.runtime.NullProgressMonitor

/**
 * 
 * @author tesonep
 */
class WollokParseHelper extends ParseHelper<WFile>{
	
	/**
	 * file is a pair fileName -> content
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
		
		val uri = resourceSetToUse.calculateUriFor(file)
		if (createFilesOnDisk) {
			val f = new File(uri.toFileString)
			
			println("?????? " + f)
			if (!f.exists) {
				f.createNewFile
			}
		}
		
		val p = parse(getAsStream(file.value), uri, null, resourceSetToUse)
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