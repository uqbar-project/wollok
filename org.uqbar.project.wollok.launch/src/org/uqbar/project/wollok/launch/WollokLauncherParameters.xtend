package org.uqbar.project.wollok.launch

import java.io.File
import java.io.FileWriter
import java.util.ArrayList
import java.util.List
import org.apache.commons.cli.CommandLine
import org.apache.commons.cli.Option
import org.apache.commons.cli.OptionBuilder
import org.apache.commons.cli.Options
import org.eclipse.osgi.util.NLS
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.parser.OptionalGnuParser

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
	boolean dynamicDiagramActivated = false
	Integer testPort = null
	Integer dynamicDiagramPort = null
	boolean jsonOutput = false
	boolean tests = false
	boolean noAnsiFormat = false
	boolean severalFiles = false
	boolean validate = true
	boolean exitOnBuildFailure = false

	Integer numberOfDecimals = null
	String printingStrategy = null
	String coercingStrategy = null

	String folder = null
	List<String> libraries = new ArrayList()

	def build() {
		val sb = new StringBuilder
		if (hasRepl) sb.append("-r").append(" ")
		if (hasRepl && dynamicDiagramActivated) sb.append("-dd").append(" ")
		sb.appendIfNotNull(requestsPort, "requestsPort")
		sb.appendIfNotNull(eventsPort, "eventsPort")
		sb.appendIfNotNull(testPort, "testPort")
		if (hasRepl && dynamicDiagramActivated) {
			sb.appendIfNotNull(dynamicDiagramPort, "dynamicDiagramPort")
		}
		if (tests) sb.append("-t ")
		if (severalFiles) sb.append("-severalFiles ")
		sb.appendIfNotNull(folder, "folder")
		if (jsonOutput) sb.append("-jsonOutput ")
		if (exitOnBuildFailure) sb.append("-exitOnBuildFailure ")
		if (noAnsiFormat) sb.append("-noAnsiFormat ")
		if (!validate) sb.append("-dontValidate ")
		buildNumberPreferences(sb)
		buildListOption(sb, libraries, "lib", ',')
		buildListOption(sb, wollokFiles, "wf", ' ')
		sb.toString
	}

	def appendIfNotNull(StringBuilder builder, Object parameterValue, String parameterKey) {
		if (parameterValue !== null) builder.append("-" + parameterKey + " " + parameterValue.toString).append(" ")
	}

	def buildNumberPreferences(StringBuilder sb) {
		if (numberOfDecimals !== null) sb.append("-numberOfDecimals ").append(numberOfDecimals).append(" ")
		if (printingStrategy !== null) sb.append("-printingStrategy ").append(printingStrategy).append(" ")
		if (coercingStrategy !== null) sb.append("-coercingStrategy ").append(coercingStrategy).append(" ")
	}

	def buildListOption(StringBuilder sb, List<String> options, String option, char separator) {
		if (!options.empty) {
			sb.append("-").append(option).append(" ")
			for (var i = 0; i < options.length; i++) {
				sb.append(options.get(i)).append(if(i < options.size() - 1) separator else " ")
			}
		}
	}

	def parse(String[] args) {
		val parser = new OptionalGnuParser
		val cmdLine = parser.parse(options, args, false)

		hasRepl = cmdLine.hasOption("r")
		dynamicDiagramActivated = cmdLine.hasOption("dd")

		tests = cmdLine.hasOption("t")
		testPort = parseParameterInt(cmdLine, "testPort")
		dynamicDiagramPort = parseParameterInt(cmdLine, "dynamicDiagramPort")

		severalFiles = cmdLine.hasOption("severalFiles")
		folder = parseParameterString(cmdLine, "folder")
		jsonOutput = cmdLine.hasOption("jsonOutput")

		noAnsiFormat = cmdLine.hasOption("noAnsiFormat")

		requestsPort = parseParameterInt(cmdLine, "requestsPort")
		eventsPort = parseParameterInt(cmdLine, "eventsPort")

		validate = !cmdLine.hasOption("dontValidate")
		exitOnBuildFailure = !cmdLine.hasOption("exitOnBuildFailure")
		numberOfDecimals = parseParameterInt(cmdLine, "numberOfDecimals", null)
		printingStrategy = parseParameterString(cmdLine, "printingStrategy")
		coercingStrategy = parseParameterString(cmdLine, "coercingStrategy")

		if ((requestsPort == 0 && eventsPort != 0) || (requestsPort != 0 && eventsPort == 0)) {
			throw new RuntimeException(Messages.WollokLauncher_REQUEST_PORT_EVENTS_PORT_ARE_BOTH_REQUIRED)
		}

		parseLibraries(cmdLine)
		parseWollokFiles(cmdLine)

		if (!wollokFiles.empty && hasRepl && !wollokFiles.get(0).endsWith(".wlk")) {
			throw new RuntimeException(Messages.WollokLauncher_REPL_ONLY_WITH_WLK_FILES)
		}

		if (wollokFiles.empty && !hasRepl) {
			throw new RuntimeException(Messages.WollokLauncher_FILE_OR_REPL_REQUIRED)
		}

		// If the parameters are empty and we are in the REPL, I generate an empty file to be able of loading the REPL
		if (wollokFiles.empty) {
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

	// apache cli has a bug proccesing multiples arguments for different options.
	// for a line such: -lib a.jar,b.jar example.wlk example2.wlk it interprets that wlk file is part of lib option.
	// In order to avoid this problem, wf option was created: -lib a.jar,b.jar -wf example.wlk example2.wlk
	// For backwards compatibility, the old style is supported if you don't need use libraries or if you use another option between libs and files:
	// -lib a.jar,b.jar -r example.wlk example2.wlk   
	def parseWollokFiles(CommandLine cmdLine) {
		wollokFiles = if(!cmdLine.hasOption("wf")) cmdLine.argList else new ArrayList(cmdLine.getOptionValues("wf"))
	}

	def parseLibraries(CommandLine cmdLine) {
		val libs = cmdLine.getOptionValues("lib")
		if (libs !== null) {
			libraries = new ArrayList(libs)
		}
	}

	def parseParameterInt(CommandLine cmdLine, String paramName) {
		parseParameterInt(cmdLine, paramName, 0)
	}

	def parseParameterInt(CommandLine cmdLine, String paramName, Integer missingValue) {
		if (!cmdLine.hasOption(paramName))
			return missingValue

		try {
			val paramParsed = cmdLine.parseParameterString(paramName)
			Integer::parseInt(paramParsed)
		} catch (NumberFormatException e) {
			throw new RuntimeException(NLS.bind(Messages.WollokLauncher_INVALID_PARAMETER_NUMBER, paramName))
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
			addOption(new Option("r", Messages.WollokLauncherOptions_REPL) => [longOpt = "repl"])
			addOption(new Option("dd", Messages.WollokLauncherOptions_DYNAMIC_DIAGRAM_ACTIVATED) => [
				longOpt = "dynamicDiagramActivated"
			])
			addOption(new Option("t", Messages.WollokLauncherOptions_RUNNING_TESTS) => [longOpt = "tests"])
			addOption(new Option("jsonOutput", Messages.WollokLauncherOptions_JSON_TEST_OUTPUT))
			addOption(new Option("noAnsiFormat", Messages.WollokLauncherOptions_DISABLE_COLORS_REPL))
			addOption(new Option("severalFiles", Messages.WollokLauncherOptions_SEVERAL_FILES))
			addOption(new Option("dontValidate", Messages.WollokLauncherOptions_DONT_VALIDATE))
			addOption(new Option("exitOnBuildFailure", Messages.WollokLauncherOptions_EXIT_ON_BUILD_FAILURE))

			add("testPort", Messages.WollokLauncherOptions_SERVER_PORT, "port", 1)
			add("dynamicDiagramPort", Messages.WollokLauncherOptions_DYNAMIC_DIAGRAM_PORT, "port", 1)
			add("requestsPort", Messages.WollokLauncherOptions_REQUEST_PORT, "port", 1)
			add("eventsPort", Messages.WollokLauncherOptions_EVENTS_PORT, "port", 1)
			add("folder", Messages.WollokLauncherOptions_SPECIFIC_FOLDER, "folder", 1)

			add("numberOfDecimals", Messages.WollokLauncherOptions_NUMBER_DECIMALS, "decimals", 1)
			add("printingStrategy", Messages.WollokLauncherOptions_DECIMAL_PRINTING_STRATEGY, "name", 1)
			add("coercingStrategy", Messages.WollokLauncherOptions_DECIMAL_CONVERSION_STRATEGY, "name", 1)

			addList("lib", Messages.WollokLauncherOptions_JAR_LIBRARIES, "libs", ',')
			addList("wf", Messages.WollokLauncherOptions_WOLLOK_FILES, "files", ' ')
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
