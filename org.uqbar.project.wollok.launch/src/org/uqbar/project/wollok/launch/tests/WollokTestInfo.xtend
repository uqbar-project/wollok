package org.uqbar.project.wollok.launch.tests

import java.io.Serializable
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.uqbar.project.wollok.wollokDsl.WTest

class WollokTestInfo implements Serializable{
	@Accessors
	val String name
	@Accessors
	val String resource;
	@Accessors
	val int lineNumber;
	
	new(WTest test){
		lineNumber = NodeModelUtils.findActualNodeFor(test).textRegionWithLineInformation.lineNumber
		resource =  EcoreUtil2.getURI(test).toString
		name = test.name
	}
}