package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import java.lang.reflect.Method
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.uqbar.project.wollok.wollokDsl.WFile
import org.eclipse.emf.ecore.EStructuralFeature

/**
 * Given an input wollok file generates a json with its AST structure.
 * 
 * @author jfernandes
 */
class WollokASTAnalyzer extends WollokChecker {

	override validate(Injector injector, Resource resource) {}
	
	override doSomething(WFile file, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		println(process(file))
	}
	
	def String process(EObject it) '''{
		«FOR p : (type + simpleProperties + features) SEPARATOR ","»
		"«p.key»" : «p.value»
		«ENDFOR»
	}'''
	
	def type(EObject it) { #["type" -> '"' + eClass.name.transform + '"'] }
	
	def simpleProperties(EObject it) {
		class.methods.filter[isSimplePropertyGetter].map[m| m.name.getterToPropertyName -> '"' + m.invoke(it).asString + '"' ]
	}
	
	def asString(Object it) { if (it == null) null else it.toString }
	
	def getterToPropertyName(String it) { substring(3).firstToLower }
	def firstToLower(String it) { Character.toLowerCase(charAt(0)) + substring(1) }
	
	def isSimplePropertyGetter(Method it) { it.declaringClass.fields.map [ name ].toList.contains(name) && parameterTypes.length == 0 && returnType.isBasicType }
	def isBasicType(Class it) { it == String || it == Boolean || it == Double || it == Integer || it.primitive }	
	
	def features(EObject it) { eContents.groupBy[eContainingFeature].entrySet.map[key?.name -> elements(value, key)] }
	
	def elements(List<EObject> it, EStructuralFeature feature) '''«IF feature.many»[«ENDIF» «map[e|process(e)].join(",")» «IF feature.many»]«ENDIF»'''
	
	// *************************************
	// ** names transformations
	// *************************************
	
	val transformations = #[ [removePrefix("W")], [removeSuffix("Expression")], [removeSuffix("Declaration")], [removeSuffix("Literal")] ]
	
	def transform(String it) { transformations.fold(it)[a, t | t.apply(a) ] }
	
	def removePrefix(String it, String prefix) { if (startsWith(prefix)) substring(1) else it }
	def removeSuffix(String it, String suffix) { if (endsWith(suffix)) substring(0, length - (suffix.length)) else it }
	
	// *************************************
	// ** main
	// *************************************
	
	def static void main(String[] args) {
		new WollokASTAnalyzer().doMain(args)
	}
	
}