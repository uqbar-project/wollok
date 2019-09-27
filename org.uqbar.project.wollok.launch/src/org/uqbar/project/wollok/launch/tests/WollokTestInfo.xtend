package org.uqbar.project.wollok.launch.tests

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.wollokDsl.WTest
import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * @author tesonep
 */
@Accessors
class WollokTestInfo implements Serializable{
	val String name
	val String resource
	val int lineNumber
	
	new(WTest test, String fileURI, boolean processingManyFiles) {
		lineNumber = NodeModelUtils.findActualNodeFor(test).textRegionWithLineInformation.lineNumber
		resource =  EcoreUtil2.getURI(test).toString
		name = test.getFullName(processingManyFiles)
	}
	
}