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
import org.uqbar.project.wollok.WollokDslStandaloneSetup
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.repl.WollokRepl
import org.uqbar.project.wollok.ui.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.ui.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.launch.io.IOUtils.*
import org.uqbar.project.wollok.WollokConstants

/**
 * Main program launcher for the interpreter.
 * Able to run in debug mode in which case it will open ports and publish
 * a service through (lite) RMI to be used from the remote debugger.
 * 
 * @author jfernandes
 */
class WollokLauncher {
	static Logger log = Logger.getLogger(WollokLauncher)
	var Injector injector

	def static void main(String[] args) {
		new WollokLauncher().doMain(args)
	}

	def doMain(String[] args) {
		try {
			log.debug("========================")
			log.debug("    Wollok Launcher")
			log.debug("========================")
			log.debug(" args: " + args.toList)

			injector = new WollokDslStandaloneSetup().createInjectorAndDoEMFRegistration

			val interpreter = injector.getInstance(WollokInterpreter)
			val parameters = new WollokLauncherParameters().parse(args)
			val fileName = parameters.wollokFiles.get(0)
			val mainFile = new File(fileName)

			val debugger = createDebugger(interpreter, parameters)
			interpreter.setDebugger(debugger)

			log.debug("Executing program...")

			log.debug("Interpreting: " + fileName)
			interpreter.interpret(mainFile.parse)

			if (parameters.hasRepl) {
				new WollokRepl(this, injector, interpreter, mainFile).startRepl()
			}

			log.debug("Program finished")

			System.exit(1)
		} catch (Throwable t) {
			log.error(t.message)
			t.printStackTrace
			System.exit(1)
		}
	}

	def createDebugger(WollokInterpreter interpreter, WollokLauncherParameters parameters) {
		if (parameters.hasDebuggerPorts) {
			createDebuggerOn(interpreter, parameters.requestsPort, parameters.eventsPort)
		} else
			new XDebuggerOff
	}

	protected def createDebuggerOn(WollokInterpreter interpreter, int listenCommandsPort, int sendEventsPort) {
		val debugger = new XDebuggerImpl
		debugger.interpreter = interpreter

		log.debug("Opening " + listenCommandsPort)
		createCommandHandler(debugger, listenCommandsPort)
		log.debug(listenCommandsPort + " opened !")

		log.debug("Opening " + sendEventsPort)
		val eventSender = new EventSender(openSocket(sendEventsPort))
		debugger.eventSender = eventSender
		eventSender.startDaemon
		log.debug(sendEventsPort + " opened !")
		debugger
	}

	def createCommandHandler(XDebugger debugger, int listenPort) {
		CommandHandlerFactory.createCommandHandler(debugger, listenPort)
	}

	def parse(File mainFile) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		this.createClassPath(mainFile, resourceSet)

		val resource = resourceSet.getResource(URI.createURI(mainFile.toURI.toString), false)
		resource.load(#{})

		validate(injector, resource)

		resource.contents.get(0) as WFile
	}

	def validate(Injector injector, Resource resource) {
		this.validate(injector,resource,[println(it.toString)],[System.exit(-1)])
	}
	
	def validate(Injector injector, Resource resource, Procedure1<? super Issue> issueHandler, Procedure1<Iterable<Issue>> after) {
		val validator = injector.getInstance(IResourceValidator)
		var issues = validator.validate(resource, CheckMode.ALL, null).filter[severity == Severity.ERROR].filter[
			code != WollokDslValidator.TYPE_SYSTEM_ERROR]
		if (!issues.isEmpty) {
			issues.forEach(issueHandler)
			after.apply(issues)
		}
	}

	// "Classpath assembly"
	def createClassPath(File file, ResourceSet resourceSet) {
		newArrayList => [
			collectWollokFiles(findProjectRoot(file.parentFile), it)
			forEach[f|resourceSet.createResource(URI.createURI(f.toURI.toString))]
		]
	}

	def void collectWollokFiles(File folder, List<File> classpath) {
		classpath.addAll(
			folder.listFiles[dir, name|
				name.endsWith("." + WollokConstants.CLASS_OBJECTS_EXTENSION) ||
					name.endsWith("." + WollokConstants.PROGRAM_EXTENSION) ||
					name.endsWith("." + WollokConstants.TEST_EXTENSION)])
		folder.listFiles[f|f.directory].forEach[collectWollokFiles(it, classpath)]
	}

	def File findProjectRoot(File folder) {

		// goes up all the way (I wanted to search for something like ".project" file but
		// the launcher is executing this interpreter with a relative path to the file, like "src/blah/myfile.wlk"
		// so I cannot make it up to the project folder :(
		if(folder.parentFile == null) folder else findProjectRoot(folder.parentFile)
	}

}
