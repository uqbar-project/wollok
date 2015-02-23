package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import java.util.List
import org.apache.log4j.Logger
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator
import org.uqbar.project.wollok.WollokDslStandaloneSetup
import org.uqbar.project.wollok.interpreter.SysoutWollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.api.XDebugger
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.ui.debugger.server.XDebuggerImpl
import org.uqbar.project.wollok.ui.debugger.server.rmi.CommandHandlerFactory
import org.uqbar.project.wollok.validation.WollokDslValidator
import org.uqbar.project.wollok.wollokDsl.WFile

import static extension org.uqbar.project.wollok.launch.io.IOUtils.*

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
	
	def doMain(String[] args){
				try {
			log.debug("========================")
			log.debug("    Wollok Launcher")
			log.debug("========================")
			log.debug(" args: " + args.toList)
			
			injector = new WollokDslStandaloneSetup().createInjectorAndDoEMFRegistration
			
			// new WollokInterpreter(new SysoutWollokInterpreterConsole)
			val interpreter = injector.getInstance(WollokInterpreter)
			val parameters = new WollokLauncherParameters().parse(args)
			
			
			val debugger = createDebugger(interpreter, parameters)
			interpreter.setDebugger(debugger)
			
			log.debug("Executing program...")
			val fileName = parameters.wollokFiles.get(0)
			
			log.debug("Interpreting: " + fileName)
			interpreter.interpret(fileName.parse)
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
		}
		else 
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
	
	
	// "Parsing"
	def parse(String fileName) { parse(new File(fileName)) }
	def parse(File file) { parse(file, createClassPath(file)) }
		
	def parse(File mainFile, List<File> classpath) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		// add classpath
		classpath.forEach[f| resourceSet.createResource(URI.createURI(f.toURI.toString))]
		
		val resource = resourceSet.getResource(URI.createURI(mainFile.toURI.toString), false)
		resource.load(#{})
		
		validate(injector, resource)
		
		resource.contents.get(0) as WFile
	}
	
	def validate(Injector injector, Resource resource) {
		val validator = injector.getInstance(IResourceValidator)
		var issues = validator.validate(resource, CheckMode.ALL, null)
				.filter[severity == Severity.ERROR]
				.filter[code != WollokDslValidator.TYPE_SYSTEM_ERROR]
		if (!issues.isEmpty) {
			issues.forEach[println(it.toString)]
			System.exit(-1)
		}
	}

	// "Classpath assembly"
	
	def createClassPath(File file) {
		newArrayList => [
			collectWollokFiles(findProjectRoot(file.parentFile), it)
		]
	}
	
	def void collectWollokFiles(File folder, List<File> classpath) {
		classpath.addAll(folder.listFiles[dir, name| name.endsWith(".wlk")])
		folder.listFiles[f| f.directory].forEach[collectWollokFiles(it, classpath)]
	}
	
	def File findProjectRoot(File folder) {
		// goes up all the way (I wanted to search for something like ".project" file but
		// the launcher is executing this interpreter with a relative path to the file, like "src/blah/myfile.wlk"
		// so I cannot make it up to the project folder :(
		if (folder.parentFile == null) folder
		else findProjectRoot(folder.parentFile)
	}	
	
}