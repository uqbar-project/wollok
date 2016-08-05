package org.uqbar.project.wollok.debugger.client.source

import java.io.File
import org.eclipse.core.runtime.AssertionFailedException
import org.eclipse.core.runtime.CoreException
import org.eclipse.debug.core.sourcelookup.AbstractSourceLookupParticipant
import org.eclipse.debug.core.sourcelookup.ISourceContainer
import org.eclipse.debug.core.sourcelookup.containers.DirectorySourceContainer
import org.uqbar.project.wollok.WollokActivator
import org.uqbar.project.wollok.debugger.model.WollokStackFrame

import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * Given a stack frame it resolves the file to be opened by the editor.
 * 
 * As the interpreter sends us the full path to the file, we don't need to do much
 * We just ask eclipse for a IFile object given that full path.
 * 
 * Superclass is actually not needed.
 * 
 * Of course this only works for wollok files.
 * 
 * @author jfernandes
 */
// I'm not sure if this is going to work for cross-project files references. 
class WollokSourceLookupParticipant extends AbstractSourceLookupParticipant {
	ISourceContainer libContainer
	
	override getSourceName(Object object) throws CoreException {
		if (object instanceof WollokStackFrame)
			(object as WollokStackFrame).sourceName
		else 
			null
	}
	
	def getOrCreateLibContainer() {
		if (libContainer == null) {
			val libLocation = WollokActivator.^default.wollokLib.location
			val libBundlePath = libLocation.substring(libLocation.lastIndexOf(':') + 1)
			
			val filePath = libBundlePath + 'src' 
			val file = new File(filePath)
			libContainer = new DirectorySourceContainer(file, true)
		}
		libContainer
	}
	
	override findSourceElements(Object object) throws CoreException {
		if (object instanceof WollokStackFrame) {
			try {
				// this can probably be done in a better way
				if (object.fileURI.toString.startsWith("classpath:")) {
//					val fileName = object.fileURI.toString.substring(object.fileURI.toString.indexOf(':') + 2)
//					return getOrCreateLibContainer.findSourceElements(fileName)
					super.findSourceElements(object)
				}
				else {
					#[object.fileURI.toIFile]	
				}
			}
			catch (AssertionFailedException e) {
				println("Error while resolving source location for " + object.fileURI)
				e.printStackTrace
				super.findSourceElements(object)	
			}
		}
		else
			super.findSourceElements(object)
	}
	
}