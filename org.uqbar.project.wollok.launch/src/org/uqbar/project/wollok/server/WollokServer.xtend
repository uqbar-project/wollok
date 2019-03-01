package org.uqbar.project.wollok.server

import com.google.inject.Inject
import com.google.inject.Provider
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.util.List
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jetty.server.Request
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.handler.AbstractHandler
import org.eclipse.xtext.resource.IResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.Wollok
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherInterpreterEvaluator
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.tests.json.WollokLauncherIssueHandlerJSON

import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import static extension org.uqbar.project.wollok.server.JSonWriter.*

/**
 * The wollok server allows you to send wollok programs, executes them 
 * and responds with a json with the static and/or runtime errors, 
 * tests results or console output.
 */
class WollokServer extends AbstractHandler {
	val parameters = new WollokLauncherParameters()
	val injector = new WollokServerSetup(parameters).createInjectorAndDoEMFRegistration => [
		injectMembers(this)
	]

	@Inject
	private Provider<XtextResourceSet> resourceSetProvider

	@Inject
	private IResourceFactory resourceFactory

	override handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) {
		val interpreter = injector.getInstance(WollokInterpreter)
		interpreter.debugger = new XDebuggerOff

		response => [
			characterEncoding = "utf8"
			contentType = "application/json"
			status = HttpServletResponse.SC_OK
		]
		baseRequest.handled = true
		val evaluator = interpreter.evaluator as WollokLauncherInterpreterEvaluator
		val testReporter = evaluator.wollokTestsReporter as WollokServerTestsReporter

		response.writer.writeJson [
			testReporter.writer = writer
			try {
				object [
					value("wollokVersion", Wollok.VERSION)

					try {
						val extension handler = new WollokLauncherIssueHandlerJSON

						val wollokRequest = request.wollokRequest
						val resource = wollokRequest.program.parseString(wollokRequest.programType)

						val issues = newArrayList
						new WollokChecker().validate(
							injector,
							resource,
							[issues.add(it)],
							[]
						)

						if (!issues.empty) {
							object("compilation") [
								array("issues", issues)[it, issue|renderIssue(issue)]
							]
						}

						interpreter.interpret(resource.contents.get(0), true)
						value("consoleOutput", interpreter.consoleOutput)

					} catch (WollokProgramExceptionWrapper exception) {
						object("runtimeError") [
							value("message", exception.wollokMessage)
							array("stackTrace", exception.wollokStrackTrace) [ it, element |
								object [
									value("contextDescription", element.call("contextDescription"))
									value("location", element.call("location"))
								]
							]
						]
					}
				]
			} catch (Exception e) {
				e.printStackTrace
			}
		]
	}

	def parse(InputStream input, String fileExtension) {
		val resourceSet = resourceSetProvider.get()

		val resource = resourceFactory.createResource(resourceSet.computeUnusedUri(fileExtension))
		resourceSet.resources.add(resource)
		resource.load(input, null)
		resource
	}

	def URI computeUnusedUri(ResourceSet resourceSet, String fileExtension) {
		val String name = WollokConstants.SYNTHETIC_FILE
		for (var i = 0; i < Integer.MAX_VALUE; i++) {
			val syntheticUri = URI.createURI(name + i + "." + fileExtension)
			if (resourceSet.getResource(syntheticUri, false) == null)
				return syntheticUri
		}
		throw new IllegalStateException()
	}

	// ************************************************************************
	// ** Request and streams handling
	// ************************************************************************
	def parseString(String program, String programType) {
		new ByteArrayInputStream(program.getBytes("UTF-8")).parse(programType)
	}

	def wollokRequest(HttpServletRequest request) {
		request.inputStream.fromJson(WollokServerRequest)
	}

	def consoleOutput(WollokInterpreter interpreter) {
		(interpreter.console as WollokServerConsole).consoleOutput
	}

	def getWollokStrackTrace(WollokProgramExceptionWrapper exception) {
		exception.wollokException.call("getStackTrace").asList.wrapped as List<WollokObject>
	}

	// ************************************************************************
	// ** Main
	// ************************************************************************
	def static void main(String[] args) {
		
		var int port = 8080;
		
		if(args.size() > 0){
			try{
				println(args.get(0));
				port = Integer.parseInt(args.get(0));
			}catch(NumberFormatException e){
				port = 8080;
				println("Using default port 8080");
			}
		}
		
		new Server(port) => [
			handler = new WollokServer
			start
			join
		]
	}
}
