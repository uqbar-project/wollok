package org.uqbar.project.wollok.launch

import java.io.File
import java.io.FileWriter
import java.util.ArrayList
import java.util.List
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.Option
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.parser.OptionalGnuParser
import org.uqbar.project.wollok.WollokConstants

/**
 * @author jfernandes
 * @author tesonep
 */
@Accessors
class WollokLauncherParameters {
	
	Integer requestsPort = null
	Integer eventsPort = null
	List<String> wollokFiles = newArrayList
	boolean hasRepl = false
	Integer testPort = null
	boolean jsonOutput = false
	boolean tests = false
	boolean noAnsiFormat = false
	List<String> libraries = new ArrayList()
	
	def build() {
		val sb = new StringBuilder
		if (hasRepl)sb.append("-r").append(" ")
		if (requestsPort !== null) sb.append("-requestsPort " + requestsPort.toString).append(" ")
		if (eventsPort !== null) sb.append("-eventsPort " + eventsPort.toString).append(" ")
		if (testPort !== null) sb.append("-testPort " + testPort.toString).append(" ")
		if (tests) sb.append("-t ")
		if (jsonOutput) sb.append("-jsonOutput ")
		if (noAnsiFormat) sb.append("-noAnsiFormat ")
		buildListOption(sb, libraries, "lib", ',')
		buildListOption(sb, wollokFiles, "wf", ' ')
		sb.toString
	}
	
	def buildListOption(StringBuilder sb, List<String> options, String option, char separator) {
		if(!options.empty) {
			sb.append("-").append(option).append(" ")
			for(var i = 0 ; i < options.length; i++) {
				sb.append(options.get(i)).append( if (i < options.size() - 1) separator else " ")
			}
		}	
	}

	def parse(String[] args) {
		val parser = new OptionalGnuParser
		val cmdLine = parser.parse(options, args, false)
		hasRepl = cmdLine.hasOption("r")
		
		tests = cmdLine.hasOption("t")
		testPort = parseParameter(cmdLine, "testPort")
		
		jsonOutput = cmdLine.hasOption("jsonOutput")
		
		noAnsiFormat = cmdLine.hasOption("noAnsiFormat")

		requestsPort = parseParameter(cmdLine, "requestsPort")
		eventsPort = parseParameter(cmdLine, "eventsPort")
		
		if ((requestsPort == 0 && eventsPort != 0) || (requestsPort != 0 && eventsPort == 0)) {
			throw new RuntimeException("Both RequestsPort and EventsPort should be informed")
		}
		
		parseLibraries(cmdLine)
		parseWollokFiles(cmdLine)
		
		if (!wollokFiles.empty && hasRepl && !wollokFiles.get(0).endsWith(".wlk")){
			throw new RuntimeException("Repl can only be used with .wlk files.")
		}
		
		if (wollokFiles.empty && !hasRepl){
			throw new RuntimeException("You must provide a file or use the REPL")
		}
		
		//If the parameters are empty and we are in the REPL, I generate an empty file to be able of loading the REPL
		if (wollokFiles.empty){
			val temp = new File(WollokConstants.REPL_FILE)
			temp.deleteOnExit
		
			val fos = new FileWriter(temp)
			fos.write('''
			object __repl {}
			''')
			fos.close
		
			wollokFiles.add(temp.absolutePath)
		}
		
		this
	}
	
	//apache cli has a bug proccesing multiples arguments for different options.
	// for a line such: -lib a.jar,b.jar example.wlk example2.wlk it interprets that wlk file is part of lib option.
	//  In order to avoid this problem, wf option was created: -lib a.jar,b.jar -wf example.wlk example2.wlk
	// For backwards compatibility, the old style is supported if you don't need use libraries or if you use another option between libs and files:
	//      -lib a.jar,b.jar -r example.wlk example2.wlk   
	def parseWollokFiles(CommandLine cmdLine) {
		wollokFiles = if(!cmdLine.hasOption("wf")) cmdLine.argList	else new ArrayList(cmdLine.getOptionValues("wf"))
	}
	
	def parseLibraries(CommandLine cmdLine) {
		val libs = cmdLine.getOptionValues("lib")
		if(libs !== null) {
			libraries = new ArrayList(libs)
		}
	}

	def parseParameter(CommandLine cmdLine, String paramName) {
		if (cmdLine.hasOption(paramName)) {
			val s = cmdLine.getOptionValue(paramName)
			try {
				Integer::parseInt(s)
			} catch (NumberFormatException e) {
				throw new RuntimeException("Invalid number value for " + paramName)
			}
		}
	}
	
	def hasDebuggerPorts() {
		this.eventsPort != 0
	}

	def options() {
		new Options => [
			addOption(new Option("r", "Starts an interactive REPL") => [longOpt = "repl"])
			addOption(new Option("t", "Running tests") => [longOpt = "tests"])
			addOption(new Option("jsonOutput", "JSON test report output"))
			addOption(new Option("noAnsiFormat", "Disables ANSI colors for the console"))

			add("testPort", "Server port for tests", "port", 1)
			add("requestsPort", "Request ports", "port", 1)
			add("eventsPort", "Events ports", "port", 1)	
			addList("lib", "libraries jars ", "libs", ',')	
			addList("wf", "wollokFiles ", "files", ' ')	

		]
	}

	def addList(Options options, String opt, String description, String argName, char separator) {
		OptionBuilder.withValueSeparator(separator)  
		OptionBuilder.hasArgs()
		OptionBuilder.withDescription(description)
		OptionBuilder.withArgName(argName)
		
		options.addOption(OptionBuilder.create(opt))
	}
	
	def add(Options options, String opt, String description, String argName, int args) {
		options.addOption(
			new Option(opt, description) => [
				it.argName = argName
				it.args = args
			]
		)
	}
	
}
