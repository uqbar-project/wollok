package org.uqbar.project.wollok.launch.repl

import com.google.inject.Injector
import java.io.BufferedReader
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.InputStreamReader
import java.io.PrintStream
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.LazyStringInputStream
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.errorHandling.StackTraceElementDTO
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.wollokDsl.WFile

import static org.uqbar.project.wollok.launch.Messages.*

import static extension org.uqbar.project.wollok.errorHandling.WollokExceptionExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class WollokRepl {
	val Injector injector
	val WollokLauncher launcher
	val WollokInterpreter interpreter
	val File mainFile
	val reader = new BufferedReader(new InputStreamReader(System.in))
	val static prompt = ">>> "
	var static whiteSpaces = ""
	val WFile parsedMainFile
	val extension ReplOutputFormatter formatter

	new(WollokLauncher launcher, Injector injector, WollokInterpreter interpreter, File mainFile, WFile parsedMainFile,
		ReplOutputFormatter formatter) {
		this.injector = injector
		this.launcher = launcher
		this.interpreter = interpreter
		this.interpreter.interactive = true
		this.mainFile = mainFile
		this.parsedMainFile = parsedMainFile
		this.formatter = formatter
	}

	def synchronized void printWelcomeStructure() {
		println(REPL_WELCOME.importantMessageStyle)
		printPrompt
	}

	def void startRepl() {
		var String input

		printWelcomeStructure

		while ((input = readInput) != "quit") {
			if (input == "/^*^?/") { // Code that indicates console cleaning
				printWelcomeStructure
			} else {
				executeInput(input)
				printPrompt
			}
		}
		printEndStructure
	}

	def synchronized printPrompt() {
		print(prompt.messageStyle)
	}

	def synchronized void printEndStructure() {
		println(REPL_END.importantMessageStyle)
	}

	def String readInput() {
		val input = reader.readLine.trim
		if (input == "") {
			printPrompt
			readInput
		} else if (input.endsWith(";"))
			input + " " + readInput
		else
			input
	}

	def synchronized executeInput(String input) {
		try {
			val returnValue = interpreter.interpret('''
				«FOR a : parsedMainFile.imports.map[importedNamespace]»
					import «a»
				«ENDFOR»
				import «parsedMainFile.implicitPackage».*
				program repl {
				«input»
				}
			'''.parseRepl(mainFile), true)
			printReturnValue(returnValue)
		} catch (Exception e) {
			resetIndent
			e.handleException
		}
	}

	// TODO: should be WollokObject
	def printReturnValue(Object obj) {
		if (obj === null)
			println("null".returnStyle)
		else if (obj instanceof WollokObject && !(obj as WollokObject).isVoid)
			doPrintReturnValue(obj)
	}

	def dispatch doPrintReturnValue(Object obj) {
		println(obj?.toString.returnStyle)
	}

	def dispatch doPrintReturnValue(WollokObject wo) {
		println(wo?.call("printString").toString.returnStyle)
	}

	// Unused
	def dispatch doPrintReturnValue(String obj) {
		println(('"' + obj + '"').returnStyle)
	}

	def parseRepl(CharSequence content, File mainFile) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		val resource = resourceSet.createResource(uriToUse(resourceSet))
		val in = new LazyStringInputStream(content.toString)

		launcher.createClassPath(mainFile, resourceSet)

		resourceSet.resources.add(resource)

		resource.load(in, #{})
		launcher.validate(injector, resource, [], [throw new ReplParserException(it)])
		resource.contents.get(0) as WFile
	}

	def uriToUse(ResourceSet resourceSet) {
		var name = WollokConstants.SYNTHETIC_FILE
		for (var i = 0; i < Integer.MAX_VALUE; i++) {
			var syntheticUri = parsedMainFile.eResource.URI.trimFileExtension.trimSegments(1).appendSegment(name + i).
				appendFileExtension(WollokConstants.PROGRAM_EXTENSION)
			if (resourceSet.getResource(syntheticUri, false) === null) {
				return syntheticUri
			}
		}
		throw new IllegalStateException
	}

	def <X> X printlnIdent(X obj) {
		print(whiteSpaces)
		println(obj)
	}

	def indent() {
		whiteSpaces = whiteSpaces + "     "
	}

	def resetIndent() {
		whiteSpaces = ""
	}

	def stackTraceAsString(Throwable e) {
		//val s = new ByteArrayOutputStream
		//e.printStackTrace(new PrintStream(s))
		//new String(s.toByteArray)
		e.message
	}

	def getNumberOfLinesBefore() {
		2 + parsedMainFile.imports.size
	}

	def toLinkForConsole(StackTraceElementDTO st) {
		st.contextForStackTrace.errorStyle + st.linkForStackTrace.linkStyle
	}

	def dispatch void handleException(ReplParserException e) {
		e.issues.forEach [
			printlnIdent(errorStyle('''«severity.name»: «message» («LINE»: «lineNumber - numberOfLinesBefore»)'''))
		]
	}

	def dispatch void handleException(Throwable e) {
		println(e.stackTraceAsString.errorStyle)
	}

	def dispatch void handleException(WollokProgramExceptionWrapper e) {
		// Wollok-level user exception
		println((e.exceptionClassName + ": " + e.wollokMessage).errorStyle)
		val errorLine = e.wollokException
			.convertStackTrace
			.toList
			.map [ stackDTO | stackDTO.toLinkForConsole ]
			.join(System.lineSeparator)
		
		if (errorLine !== null && !errorLine.equals("")) {
			printlnIdent(errorLine.errorStyle)
		}
	}

	def dispatch void handleException(WollokInterpreterException e) {
		if (e.lineNumber > numberOfLinesBefore) {
			printlnIdent('''«WVM_ERROR» («e.lineNumber - numberOfLinesBefore»): «e.nodeText»:'''.errorStyle)
		}

		if (e.cause !== null) {
			indent
			handleException(e.cause)
		}
	}

	def getPrompt() {
		prompt.messageStyle.toString
	}

}
