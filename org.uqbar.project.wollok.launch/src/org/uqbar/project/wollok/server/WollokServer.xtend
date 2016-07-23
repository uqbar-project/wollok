package org.uqbar.project.wollok.server

import com.google.gson.Gson
import com.google.inject.Inject
import com.google.inject.Provider
import java.io.ByteArrayInputStream
import java.io.InputStream
import java.io.InputStreamReader
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.jetty.server.Request
import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.handler.AbstractHandler
import org.eclipse.xtext.resource.IResourceFactory
import org.eclipse.xtext.resource.XtextResourceSet
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

class WollokServer extends AbstractHandler {
	extension Gson = new Gson
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
		val writer = response.writer.newJsonWriter
		val evaluator = interpreter.evaluator as WollokLauncherInterpreterEvaluator
		val testReporter = evaluator.wollokTestsReporter as WollokServerTestsReporter
		testReporter.writer = writer

		try {
			writer => [
				beginObject => [
					name("wollokVersion").value(Wollok.VERSION)
	
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
							name("compilation").beginObject => [
								name("issues")
								beginArray
								issues.forEach[issue|renderIssue(issue)]
								endArray
							]
							endObject
						}
	
						interpreter.interpret(resource.contents.get(0), true)
						name("consoleOutput")
						value((interpreter.console as WollokServerConsole).consoleOutput)
					} catch (WollokProgramExceptionWrapper exception) {
						writer.name("runtimeError").beginObject => [
							name("message").value(exception.wollokException.call("getMessage").toString)
							name("stackTrace")
							beginArray
							exception.wollokException.call("getStackTrace").asList.wrapped.forEach [ element |
								val object = element as WollokObject
								beginObject
								name("contextDescription").value(object.call("contextDescription")?.toString)
								name("location").value(object.call("location").toString)
								endObject
							]
							endArray
						]
						endObject
					}
				]
				endObject
			]
		}
		catch (Exception e) {
			e.printStackTrace
		}
		finally {
			writer.close		
		}
	}

	def parse(InputStream input, String fileExtension) {
		val resourceSet = resourceSetProvider.get()

		val resource = resourceFactory.createResource(resourceSet.computeUnusedUri(fileExtension))
		resourceSet.resources.add(resource)
		resource.load(input, null)
		resource
	}

	def URI computeUnusedUri(ResourceSet resourceSet, String fileExtension) {
		val String name = "__synthetic"
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
		val reader = new InputStreamReader(request.inputStream)
		reader.fromJson(WollokServerRequest)
	}

	// ************************************************************************
	// ** Main
	// ************************************************************************
	def static void main(String[] args) {
		new Server(8080) => [
			handler = new WollokServer
			start
			join
		]
	}
}
