package org.uqbar.project.wollok.interpreter

import com.google.inject.Injector
import java.io.File
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.uqbar.project.wollok.WollokDslStandaloneSetup
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Standalone interpreter.
 * It's a simple java program as a main.
 * Internally it delegates to WollokInterpreter (the same being used within eclipse IDE).
 * 
 * @deprecated This will be replaced with WollokLauncher which also implements debugging mechanism. 
 * 
 * @author jfernandes
 */
@Deprecated
class WollokInterpreterStandalone {
	
	def static void main(String[] args) {
		if (args.isEmpty) {
			throw new RuntimeException("Debe invocar este interprete con la ruta completa a un archivo .wlk como argumento!")
		}
		val fileName = args.get(0)
		val model = parse(fileName)
		new WollokInterpreter(new SysoutWollokInterpreterConsole).interpret(model)
	}
	
	def static parse(String fileName) { parse(new File(fileName)) }
	def static parse(File file) { parse(file.toURI, createClassPath(file)) }
	
	// "Classpath assembly"
	
	def static createClassPath(File file) {
		newArrayList => [
			collectWollokFiles(findProjectRoot(file.parentFile), it)
		]
	}
	
	def static void collectWollokFiles(File folder, List<File> classpath) {
		classpath.addAll(folder.listFiles[dir, name| name.endsWith(".wlk")])
		folder.listFiles[f| f.directory].forEach[collectWollokFiles(it, classpath)]
	}
	
	def static File findProjectRoot(File folder) {
		// goes up all the way (I wanted to search for something like ".project" file but
		// the launcher is executing this interpreter with a relative path to the file, like "src/blah/myfile.wlk"
		// so I cannot make it up to the project folder :(
		if (folder.parentFile == null) folder
		else findProjectRoot(folder.parentFile)
	}
	
	// "Parsing"
		
	def static parse(java.net.URI uri, List<File> classpath) {
		val injector = new WollokDslStandaloneSetup().createInjectorAndDoEMFRegistration
		val resourceSet = injector.getInstance(XtextResourceSet)
		// add classpath
		classpath.forEach[f| resourceSet.createResource(URI.createURI(f.toURI.toString))]
		
		val resource = resourceSet.getResource(URI.createURI(uri.toString), false)
		resource.load(#{})
		
		validate(injector, resource)
		
		resource.contents.get(0) as WFile
	}
	
	def static validate(Injector injector, Resource resource) {
		val validator = injector.getInstance(IResourceValidator)
		var issues = validator.validate(resource, CheckMode.ALL, null)
				.filter[severity == Severity.ERROR]
				.filter[code != WollokDslValidator.TYPE_SYSTEM_ERROR]
		if (!issues.isEmpty) {
			issues.forEach[println(it.toString)]
			System.exit(-1)
		}
	}
	
}