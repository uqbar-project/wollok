package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile

/**
 * Wollok checker program.
 * It's kind of a linter (or a compiler, just that it doesn't compile anything :P)
 * 
 * Parses and validates a given program.
 * 
 * @author jfernandes
 */
class WollokChecker {
	protected static Logger log = Logger.getLogger(WollokLauncher)
	var Injector injector
	
	def static void main(String[] args) {
		new WollokChecker().doMain(args)
	}
	
	def doMain(String[] args) {
		try {
			log.debug("========================")
			log.debug("    Wollok Launcher")
			log.debug("========================")
			log.debug(" args: " + args.toList)
			
			if (args.contains("--version")) {
				println("Wollok v1.1.0") // TODO: compute real version number 
				System.exit(0)
			}
			
			val parameters = new WollokLauncherParameters().parse(args)
			val fileName = parameters.wollokFiles.get(0)
			val mainFile = new File(fileName)

			injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration

			log.debug("Parsing program...")
			val parsed = mainFile.parse
			
			doSomething(parsed, injector, mainFile, parameters)
			
			log.debug("Program finished")
		}
		catch (Throwable t) {
			log.error(t.message)
			t.printStackTrace
			System.exit(1)
		}
	}
	
	def void doSomething(WFile file, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		// by default the checker does nothing
	}
	
	def parse(File mainFile) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		this.createClassPath(mainFile, resourceSet)

		val resource = resourceSet.getResource(URI.createURI(mainFile.toURI.toString), false)
		resource.load(#{})

		validate(injector, resource)

		resource.contents.get(0) as WFile
	}
	
		// "Classpath assembly"
	def createClassPath(File file, ResourceSet resourceSet) {
/* 
		newArrayList => [
			collectWollokFiles(findProjectRoot(file.parentFile), it)
			forEach[f|resourceSet.createResource(URI.createURI(f.toURI.toString))]
		]
*/
		newArrayList => [
			resourceSet.createResource(URI.createURI(file.toURI.toString))
		]
	}
	
	def void collectWollokFiles(File folder, List<File> classpath) {
		classpath.addAll(
			folder.listFiles[dir, name|
				name.endsWith("." + WollokConstants.CLASS_OBJECTS_EXTENSION) ||
					name.endsWith("." + WollokConstants.PROGRAM_EXTENSION) ||
					name.endsWith("." + WollokConstants.TEST_EXTENSION)])
		folder.listFiles[ directory ].forEach[ collectWollokFiles(it, classpath) ]
	}
	
	def validate(Injector injector, Resource resource) {
		this.validate(injector,resource,[println(formattedIssue)],[ System.exit(-1) ])
	}
	
	def String formattedIssue(Issue it) {
		// COLUMN: investigate how to calculate the column number from the offset !
		'''«uriToProblem?.trimFragment.toFileString»:«lineNumber»:«if (offset == null) 1 else offset» «severity.name» «message»'''
	}
	
	def validate(Injector injector, Resource resource, Procedure1<? super Issue> issueHandler, Procedure1<Iterable<Issue>> after) {
		val validator = injector.getInstance(IResourceValidator)
		val issues = validator.validate(resource, CheckMode.ALL, null)
		// WARNINGS
		issues.filter[ severity == Severity.WARNING ].forEach(issueHandler)
		// ERRORS 
		val errors = issues.filter[severity == Severity.ERROR && code != WollokDslValidator.TYPE_SYSTEM_ERROR]
		if (!errors.isEmpty) {
			errors.forEach(issueHandler)
			after.apply(errors)
		}
	}
	
	def File findProjectRoot(File folder) {
		// goes up all the way (I wanted to search for something like ".project" file but
		// the launcher is executing this interpreter with a relative path to the file, like "src/blah/myfile.wlk"
		// so I cannot make it up to the project folder :(
		if (folder.parentFile == null) folder else findProjectRoot(folder.parentFile)
	}
	
}