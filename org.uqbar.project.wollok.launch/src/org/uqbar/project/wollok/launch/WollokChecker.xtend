package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
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
import org.uqbar.project.wollok.interpreter.nativeobj.WollokNumbersPreferences

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
	protected var Injector injector
	protected var parameters = new WollokLauncherParameters()

	def static void main(String[] args) {
		new WollokChecker().doMain(args)
	}

	def String processName() {
		"Wollok Launcher"
	}

	/**
	 * By default WollokChecker always validates
	 */
	def shouldValidate() { true }

	def doMain(String[] args) {
		try {
			log.debug("========================")
			log.debug("    " + this.processName)
			log.debug("========================")
			log.debug(" args: " + args.toList)

			if (args.contains("--version")) {
				println("Wollok v" + Wollok.VERSION)
				System.exit(0)
			}

			parameters.parse(args)

			this.configureNumberPreferences(parameters)

			injector = new WollokLauncherSetup(parameters).createInjectorAndDoEMFRegistration

			this.doConfigureParser(parameters)

			if (parameters.severalFiles) {
				// Tests may run several files
				launch(parameters.wollokFiles, parameters)
			} else {
				// Rest of executables just launch one file
				val fileName = parameters.wollokFiles.head
				launch(fileName, parameters)
			}

			log.debug("Program finished")
		} catch (Throwable t) {
			log.error("Checker error : " + t.class.name)
			t.stackTrace.forEach [ ste |
				log.error('''«ste.methodName» («ste.fileName»:«ste.lineNumber»)''')
			]
			System.exit(1)
		}
	}

	def configureNumberPreferences(WollokLauncherParameters parameters) {
		if (parameters.numberOfDecimals !== null)
			WollokNumbersPreferences.instance.decimalPositions = parameters.numberOfDecimals

		if (parameters.coercingStrategy !== null)
			WollokNumbersPreferences.instance.setNumberCoercingStrategyByName(parameters.coercingStrategy)

		if (parameters.printingStrategy !== null)
			WollokNumbersPreferences.instance.setNumberPrintingStrategyByName(parameters.printingStrategy)
	}

	def void doConfigureParser(WollokLauncherParameters parameters) {}

	def void launch(List<String> fileNames, WollokLauncherParameters parameters) {
		doSomething(fileNames, injector, parameters)
	}

	def launch(String fileName, WollokLauncherParameters parameters) {
		val mainFile = new File(fileName)
		log.debug("Parsing program...")
		doSomething(mainFile.parse(parameters), injector, mainFile, parameters)
	}

	def void doSomething(List<String> fileNames, Injector injector, WollokLauncherParameters parameters) {
		// by default the checker does nothing
	}

	def void doSomething(WFile file, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		// by default the checker does nothing
	}

	def parse(File mainFile, WollokLauncherParameters parameters) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		this.createClassPath(mainFile, resourceSet)

		val resource = resourceSet.getResource(URI.createURI(mainFile.toURI.toString), false)
		resource.load(#{})

		if (shouldValidate) validate(injector, resource, parameters)

		resource.contents.get(0) as WFile
	}

	def parse(List<File> mainFiles, WollokLauncherParameters parameters) {
		mainFiles.map[mainFile|mainFile.parse(parameters) as EObject]
	}

	def createClassPath(File file, ResourceSet resourceSet) {
		newArrayList => [
			resourceSet.createResource(URI.createURI(file.toURI.toString))
		]
	}

	def void collectWollokFiles(File folder, List<File> classpath) {
		classpath.addAll(
			folder.listFiles [ dir, name |
			name.endsWith("." + WollokConstants.CLASS_OBJECTS_EXTENSION) ||
				name.endsWith("." + WollokConstants.PROGRAM_EXTENSION) ||
				name.endsWith("." + WollokConstants.TEST_EXTENSION)
		])
		folder.listFiles[directory].forEach[collectWollokFiles(it, classpath)]
	}

	def validate(Injector injector, Resource resource, WollokLauncherParameters parameters) {
		val handler = injector.getInstance(WollokLauncherIssueHandler)
		this.validate(injector, resource, [handler.handleIssue(it)], blockErrorHandler(handler, parameters))
	}

	def Procedure1<Iterable<Issue>> blockErrorHandler(WollokLauncherIssueHandler handler,
		WollokLauncherParameters parameters) {
		[handler.finished]
	}

	def validate(Injector injector, Resource resource, Procedure1<? super Issue> issueHandler,
		Procedure1<Iterable<Issue>> after) {
		val validator = injector.getInstance(IResourceValidator)
		val issues = validator.validate(resource, CheckMode.ALL, null)
		// WARNINGS
		issues.filter[severity == Severity.WARNING].forEach(issueHandler)
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
		if(folder.parentFile === null) folder else findProjectRoot(folder.parentFile)
	}

}
