package org.uqbar.project.wollok.server

import com.google.gson.Gson
import com.google.inject.Inject
import com.google.inject.Provider
import java.io.InputStream
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
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.Wollok
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.tests.json.WollokLauncherIssueHandlerJSON
import static extension org.uqbar.project.wollok.lib.WollokSDKExtensions.*
import org.uqbar.project.wollok.interpreter.core.WollokObject

class WollokServer extends AbstractHandler {
	val gson = new Gson
	val parameters = new WollokLauncherParameters().parse(#["-r"])
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
		val writer = gson.newJsonWriter(response.writer)
		writer => [
			beginObject => [
				name("wollokVersion").value(Wollok.VERSION)

				try {
					val extension handler = new WollokLauncherIssueHandlerJSON
					val issues = newArrayList
					val resource = request.inputStream.parse

					new WollokChecker().validate(
						injector,
						resource,
						[issues.add(it)],
						[]
					)
					
					if (issues.empty) {
						interpreter.interpret(resource.contents.get(0), true)
						name("consoleOutput")
						value((interpreter.console as WollokServerConsole).consoleOutput)	
					}
					else {
						name("compilation").beginObject => [
							name("issues")
							beginArray
								issues.forEach[issue|renderIssue(issue)]						
							endArray							
						]
						endObject
					}	
				}
				catch (WollokProgramExceptionWrapper exception) {
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

		writer.close
	}

	def parse(InputStream input) {
		val resourceSet = resourceSetProvider.get()

		val resource = resourceFactory.createResource(resourceSet.computeUnusedUri)
		resourceSet.resources.add(resource)
		resource.load(input, null)
		resource	
	}

	def URI computeUnusedUri(ResourceSet resourceSet) {
		val String name = "__synthetic"
		for (var i = 0; i < Integer.MAX_VALUE; i++) {
			val syntheticUri = URI.createURI(name + i + ".wpgm")
			if (resourceSet.getResource(syntheticUri, false) == null)
				return syntheticUri
		}
		throw new IllegalStateException()
	}

	def static void main(String[] args) {
		new Server(8080) => [
			handler = new WollokServer
			start
			join
		]
	}
}
