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
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.stack.VoidObject
import org.uqbar.project.wollok.launch.WollokLauncher
import org.uqbar.project.wollok.wollokDsl.WFile

import static org.fusesource.jansi.Ansi.*
import static org.fusesource.jansi.Ansi.Color.*

import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
// I18N
class WollokRepl {
	static val COLOR_RETURN_VALUE = BLUE
	static val COLOR_ERROR = RED
	static val COLOR_REPL_MESSAGE = CYAN 
	
	val Injector injector
	val WollokLauncher launcher
	val WollokInterpreter interpreter
	val File mainFile
	val reader = new BufferedReader(new InputStreamReader(System.in))
	val static prompt = ">>> "
	var static whiteSpaces = ""
	val WFile parsedMainFile

	new(WollokLauncher launcher, Injector injector, WollokInterpreter interpreter, File mainFile, WFile parsedMainFile) {
		this.injector = injector
		this.launcher = launcher
		this.interpreter = interpreter
		this.mainFile = mainFile
		this.parsedMainFile = parsedMainFile
	}

	def void startRepl() {
		var String input

		println("Wollok interactive console (type \"quit\" to quit): ".importantMessageStyle)
		printPrompt
		
		while ((input = readInput) != "quit") {
			executeInput(input)
			printPrompt
		}
	}
	
	def printPrompt() {
		print(prompt.messageStyle)
	}
	
	def String readInput() {
		val input = reader.readLine.trim
		if (input == "") {
			printPrompt
			readInput
		}
		else
			if (input.endsWith(";")) 
				input + " " + readInput
			else input
	}
	
	def executeInput(String input) {
			try {
				val returnValue = interpreter.interpret(
					'''
						«FOR a : parsedMainFile.imports.map[importedNamespace]»
						import «a»
						«ENDFOR»
						import «parsedMainFile.fileName».*
						program repl {
						«input»
						}
					'''.parseRepl(mainFile),true)
				printReturnValue(returnValue)
			} 
			catch (Exception e) {
				resetIndent
				handleException(e)
			}
	}
	
	def printReturnValue(Object obj) {
		if (obj == null)
			println("null".returnStyle)
		else 
			doPrintReturnValue(obj)
	}
	
	def dispatch doPrintReturnValue(Object obj){
		println(obj?.toString.returnStyle)
	}

	def dispatch doPrintReturnValue(String obj){
		println(('"' + obj + '"').returnStyle)
	}

	def dispatch doPrintReturnValue(VoidObject obj){}

	def parseRepl(CharSequence content, File mainFile) {
		val resourceSet = injector.getInstance(XtextResourceSet)
		val resource = resourceSet.createResource(uriToUse(resourceSet))
		val in = new LazyStringInputStream(content.toString)

		launcher.createClassPath(mainFile, resourceSet)

		resourceSet.resources.add(resource)

		resource.load(in, #{});
		launcher.validate(injector, resource, [], [throw new ReplParserException(it)])
		resource.contents.get(0) as WFile
	}

	def uriToUse(ResourceSet resourceSet) {
		var name = "__synthetic";
		for (var i = 0; i < Integer.MAX_VALUE; i++) {
			var syntheticUri = parsedMainFile.eResource.URI.trimFileExtension.trimSegments(1).appendSegment(name + i).appendFileExtension(WollokConstants.PROGRAM_EXTENSION)
			if (resourceSet.getResource(syntheticUri, false) == null) {
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

	def dispatch void handleException(ReplParserException e) {
		e.issues.forEach [
			printlnIdent(errorStyle("" + severity.name + ":" + message + "(line: " + (lineNumber - numberOfLinesBefore) + ")"))
		]
	}
	
	def dispatch void handleException(Throwable e) {
		println(e.stackTraceAsString.errorStyle)
	}
	
	def stackTraceAsString(Throwable e) {
		val s = new ByteArrayOutputStream
		e.printStackTrace(new PrintStream(s))
		new String(s.toByteArray)
	}

	def getNumberOfLinesBefore(){
		2 + parsedMainFile.imports.size
	}

	def dispatch void handleException(WollokProgramExceptionWrapper e) {
		// Wollok-level user exception
		e.wollokException.call("printStackTrace")
	}

	def dispatch void handleException(WollokInterpreterException e) {
		if (e.lineNumber > numberOfLinesBefore) {
			printlnIdent('''WVM Error in line («e.lineNumber - numberOfLinesBefore»): «e.nodeText»:'''.errorStyle)
		}
		
		if (e.cause != null) {
			indent
			handleException(e.cause)
		}
	}
	
	// ********** STYLING
	
	// applies styles for errors
	def errorStyle(CharSequence msg) { ansi.fg(COLOR_ERROR).a(msg).reset }
	def importantMessageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).bold.a(msg).reset }
	def messageStyle(CharSequence msg) { ansi.fg(COLOR_REPL_MESSAGE).a(msg).reset }
	def returnStyle(CharSequence msg) { ansi().fg(COLOR_RETURN_VALUE).a(msg).reset }
}
