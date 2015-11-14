package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.wollokDsl.WFile
import java.util.List

/**
 * @author jfernandes
 */
class WollokASTAnalyzer extends WollokChecker{

	override validate(Injector injector, Resource resource) { 
	}
	
	override doSomething(WFile file, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		println(process(file))
	}
	
	def String process(EObject obj) '''{
		"type" : "«obj.eClass.name.removeW.removeExpression»",
		«IF !obj.eContents.empty»
		«obj.eContents.groupBy[eContainingFeature].entrySet.map['''"«key?.name»" : «elements(value)»'''].join(",")»
		«ENDIF»
	}'''
	
	def elements(List<EObject> it) '''[«map[e|process(e)].join(",")»]'''
	
	def removeW(String string) {
		if (string.startsWith("W"))
			string.substring(1)
		else
			string
	}
	
	def removeExpression(String string) {
		if (string.endsWith("Expression"))
			string.substring(0, string.length - ("Expression".length))
		else
			string
	}
	
	def static void main(String[] args) {
		new WollokASTAnalyzer().doMain(args)
	}
	
	
	
	
}