package org.uqbar.project.wollok.wollokDoc

import com.google.inject.Inject
import java.io.File
import java.io.PrintWriter
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*
import com.google.common.io.Files

/**
 * WollokDoc Parser should be called with a single argument:
 * 	the folder where wlk files are located
 * 
 * @author dodain
 */
class WollokDocParser extends WollokChecker {
	
	val static HEADER_ON = "<H1>"
	val static HEADER_OFF = "</H1>"
	val static HEADER2_ON = "<H2>"
	val static HEADER2_OFF = "</H2>"
	val static HEADER3_ON = "<H3>"
	val static HEADER3_OFF = "</H3>"
	val static HORIZONTAL_LINE = "<HR>"
	val static BOLD_ON = "<B>"
	val static BOLD_OFF = "</B>"
	val static ITALIC_ON = "<I>"
	val static ITALIC_OFF = "</I>"
	val static PARAGRAPH_ON = "<P>"
	val static PARAGRAPH_OFF = "</P>"
	val static SPACE = " "
	val static TABLE_ON = "<TABLE>"
	val static TABLE_OFF = "</TABLE>"
	val static TABLE_HEADING_ON = "<TH>"
	val static TABLE_HEADING_OFF = "</TH>"
	val static TABLE_DATA_ON = "<TD>"
	val static TABLE_DATA_OFF = "</TD>"
	val static TABLE_ROW_ON = "<TR>"
	val static TABLE_ROW_OFF = "</TR>"
	val static LINE_BREAK = "<BR>"
	val static wollokDocTokens = #["author", "since", "param", "return", "see", "private", "returns", "throws", "noInstantiate"]
	var PrintWriter wollokDocFile
			
	@Inject MultiLineCommentDocumentationProvider multilineProvider
	
	def static void main(String[] args) {
		new WollokDocParser().doMain(args)
	}
	
	override String processName() {
		"WollokDoc Parser"
	}
	
	override doConfigureParser(WollokLauncherParameters parameters) {
		injector.injectMembers(this)
	}

	override launch(String folder, WollokLauncherParameters parameters) {
        new DirExplorer(filterWollokElements, launchWollokDocGeneration).explore(new File(folder))
	}
	
	def dispatch generateWollokDocFile(WFile file, File mainFile) {
		wollokDocFile = new PrintWriter("wollokDoc.html", "UTF-8")
		Files.newWriter(new File("wollo"))
		file => [
			elements.forEach [ generateWollokDoc ]
		]
		wollokDocFile.close
	}
	
	def dispatch void generateWollokDoc(EObject o) {
	}

	def dispatch void generateWollokDoc(WConstructor c) {
		writeFile(BOLD_ON + WollokConstants.CONSTRUCTOR + BOLD_OFF + "(" + c.parameters.map[name].join(", ") + ")")
		c.showComment
		writeFile(HORIZONTAL_LINE)
	}
	
	def dispatch void generateWollokDoc(WMethodDeclaration m) {
		val comment = m.comment
		val abstractDescription = if (m.abstract) ITALIC_ON + "abstract" + ITALIC_OFF + SPACE else ""
		val nativeDescription = if (m.native) ITALIC_ON + "native" + ITALIC_OFF + SPACE else ""
		writeFile(TABLE_DATA_ON + BOLD_ON + m.name + BOLD_OFF + m.parametersAsString + TABLE_DATA_OFF +
			TABLE_DATA_ON + nativeDescription +
			comment + TABLE_DATA_OFF)
	}
	
	def dispatch void generateWollokDoc(WMethodContainer mc) {
		header(mc.abstractionName + SPACE + mc.name)
		if (mc.parent !== null) {
			header2("Inherits from " + mc.parent.name)
		}
		mc.showComment
		val constructors = mc.members.filter(WConstructor)
		if (!constructors.isEmpty) {
			header2("Constructors")
			writeFile(TABLE_ON)
			constructors.forEach [ generateWollokDoc ]
			writeFile(TABLE_OFF)
			writeFile(HORIZONTAL_LINE)
		}
		if (!mc.methods.isEmpty) {
			header2("Behavior")
			writeFile(TABLE_ON)
			tableHeader("Method", "Description")
			mc.methods.forEach [ 
				writeFile(TABLE_ROW_ON)
				generateWollokDoc
				writeFile(TABLE_ROW_OFF)
			]
			writeFile(TABLE_OFF)
		}
		writeFile(HORIZONTAL_LINE)
	}

	def void showComment(EObject o) {
		val comment = o.comment
		if (comment !== null) {
			writeFile(PARAGRAPH_ON + SPACE + comment + PARAGRAPH_OFF)
		}
	}
	
	def void header(String text) {
		writeFile(HEADER_ON + SPACE + text + HEADER_OFF)
	}
	
	def void header2(String text) {
		writeFile(HEADER2_ON + SPACE + text + HEADER2_OFF)
	}
	
	def void header3(String text) {
		writeFile(HEADER3_ON + SPACE + text + HEADER3_OFF)
	}
	
	def void tableHeader(String... headers) {
		writeFile(TABLE_ROW_ON)
		headers.forEach [ writeFile(TABLE_HEADING_ON + it + TABLE_HEADING_OFF) ]
		writeFile(TABLE_ROW_OFF)
	}

	def String comment(EObject o) {
		val comment = (multilineProvider.getDocumentation(o) ?: "")
			.replace(System.lineSeparator, LINE_BREAK)
		wollokDocTokens.fold(comment, [ newComment, token | 
			newComment.replace("@" + token, BOLD_ON + token + BOLD_OFF) 
		])
	}
	
	def Filter filterWollokElements() {
		[ int level, String path, File file |
			path.endsWith(".wlk")
		]
	}
	
	def FileHandler launchWollokDocGeneration() {
		[ int level, String path, File file | 
			log.debug("Parsing program...")
			WollokDocParser.this.generateWollokDocFile(file.parse, file)
		]
	}
	
	def void writeFile(String text) {
		println(text)
		wollokDocFile.println(text)
	}
}