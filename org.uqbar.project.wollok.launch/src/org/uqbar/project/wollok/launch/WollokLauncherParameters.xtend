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
 * @author dodain - added severalFiles, a specific folder and a list of files for tests
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
	boolean severalFiles = false
	
	Integer numberOfDecimals = null
	String printingStrategy = null
	String coercingStrategy = null
	
	String folder = null
	List<String> libraries = new ArrayList()
	
	def build() {
		val sb = new StringBuilder
		if (hasRepl)sb.append("-r").append(" ")
		if (requestsPort !== null) sb.append("-requestsPort " + requestsPort.toString).append(" ")
		if (eventsPort !== null) sb.append("-eventsPort " + eventsPort.toString).append(" ")
		if (testPort !== null) sb.append("-testPort " + testPort.toString).append(" ")
		if (tests) sb.append("-t ")
		if (severalFiles) sb.append("-severalFiles ")
		if (folder !== null) sb.append("-folder " + folder).append(" ")
		if (jsonOutput) sb.append("-jsonOutput ")
		if (noAnsiFormat) sb.append("-noAnsiFormat ")
		
		buildNumberPreferences(sb)
		
		buildListOption(sb, libraries, "lib", ',')
		buildListOption(sb, wollokFiles, "wf", ' ')
		sb.toString
	}

	def buildNumberPreferences(StringBuilder sb){
		if(numberOfDecimals !== null) sb.append("-numberOfDecimals ").append(numberOfDecimals).append(" ")
		if(printingStrategy !== null) sb.append("-printingStrategy ").append(printingStrategy).append(" ")
		if(coercingStrategy !== null) sb.append("-coercingStrategy ").append(coercingStrategy).append(" ")
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
		
		args.forEach[ println(it) ]
		
		hasRepl = cmdLine.hasOption("r")
		
		tests = cmdLine.hasOption("t")
		testPort = parseParameterInt(cmdLine, "testPort")
		
		severalFiles = cmdLine.hasOption("severalFiles")
		folder = parseParameterString(cmdLine, "folder")
		
		jsonOutput = cmdLine.hasOption("jsonOutput")
		
		noAnsiFormat = cmdLine.hasOption("noAnsiFormat")

		requestsPort = parseParameterInt(cmdLine, "requestsPort")
		eventsPort = parseParameterInt(cmdLine, "eventsPort")
		
		numberOfDecimals = parseParameterInt(cmdLine, "numberOfDecimals", null)
		printingStrategy = parseParameterString(cmdLine, "printingStrategy")
		coercingStrategy = parseParameterString(cmdLine, "coercingStrategy")
		
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

	def parseParameterInt(CommandLine cmdLine, String paramName){
		parseParameterInt(cmdLine, paramName, 0)
	}

	def parseParameterInt(CommandLine cmdLine, String paramName, Integer missingValue) {
		if (!cmdLine.hasOption(paramName)) 
			return missingValue

		try {			
			val paramParsed = cmdLine.parseParameterString(paramName)
			Integer::parseInt(paramParsed)
		} catch (NumberFormatException e) {
			throw new RuntimeException("Invalid number value for " + paramName)
		}
	}

	def parseParameterString(CommandLine cmdLine, String paramName) {
		if (cmdLine.hasOption(paramName)) {
			cmdLine.getOptionValue(paramName)
		} else {
			null
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
			addOption(new Option("severalFiles", "Allows to run several files alltogether"))

			add("testPort", "Server port for tests", "port", 1)
			add("requestsPort", "Request ports", "port", 1)
			add("eventsPort", "Events ports", "port", 1)	
			add("folder", "Specific folder", "folder", 1)
			
			add("numberOfDecimals", "Number of decimals to use in the printing and rounding", "decimals", 1)
			add("printingStrategy", "Strategy to use when printing a number", "name", 1)
			add("coercingStrategy", "Strategy to use when converting numbers", "name", 1)
			
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
