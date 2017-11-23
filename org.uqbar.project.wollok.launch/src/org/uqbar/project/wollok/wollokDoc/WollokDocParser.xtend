package org.uqbar.project.wollok.wollokDoc

import com.google.common.base.Charsets
import com.google.common.io.Files
import com.google.inject.Inject
import java.io.BufferedWriter
import java.io.File
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.documentation.impl.MultiLineCommentDocumentationProvider
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.launch.WollokChecker
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructor
import org.uqbar.project.wollok.wollokDsl.WFile
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*
import static extension org.uqbar.project.wollok.model.WollokModelExtensions.*

/**
 * WollokDoc Parser should be called with a single argument:
 * 	the folder where wlk files are located
 * 
 * @author dodain
 */
class WollokDocParser extends WollokChecker {
	
	val static HEADER_ON = "<h2>"
	val static HEADER_OFF = "</h2>"
	val static HEADER2_ON = "<h3>"
	val static HEADER2_OFF = "</h3>"
	val static HEADER3_ON = "<h4>"
	val static HEADER3_OFF = "</h4>"
	val static HORIZONTAL_LINE = "<hr>"
	val static BOLD_ON = "<b>"
	val static BOLD_OFF = "</b>"
	val static ITALIC_ON = "<i>"
	val static ITALIC_OFF = "</i>"
	val static PARAGRAPH_ON = "<p>"
	val static PARAGRAPH_OFF = "</p>"
	val static SPACE = " "
	val static TABLE_ON = "<table class=\"table table-striped table-hover table-sm\">"
	val static TABLE_OFF = "</table>"
	val static TABLE_HEADING_CONF_ON = "<thead>"
	val static TABLE_HEADING_CONF_OFF = "</thread>"
	val static TABLE_BODY_ON = "<tbody>"
	val static TABLE_BODY_OFF = "</tbody>"
	val static TABLE_HEADING_ON = "<th class=\"blue-grey lighten-2\">"
	val static TABLE_HEADING_OFF = "</th>"
	val static TABLE_DATA_ON = "<td>"
	val static TABLE_DATA_OFF = "</td>"
	val static TABLE_ROW_ON = "<tr>"
	val static TABLE_ROW_OFF = "</tr>"
	val static LINE_BREAK = "<br>"
	val static wollokDocTokens = #["author", "since", "param", "see", "private", "returns", "return", "throws", "noInstantiate"]
	var BufferedWriter wollokDocFile
	val allFiles = <File>newArrayList
	var String outputFolder
			
	@Inject MultiLineCommentDocumentationProvider multilineProvider
	
	def static void main(String[] args) {
		new WollokDocParser().doMain(args)
	}
	
	override String processName() {
		"WollokDoc Parser"
	}
	
	override doConfigureParser(WollokLauncherParameters parameters) {
		injector.injectMembers(this)
		outputFolder = parameters.folder
	}

	override launch(String folder, WollokLauncherParameters parameters) {
        new DirExplorer(filterWollokElements, launchWollokDocGeneration) => [
        	explore(new File(folder))
        	writeNavbar
        ]
	}
	
	def void writeNavbar() {
		val file = new File(outputFolder + File.separator + "index.html")
		wollokDocFile = Files.newWriter(file, Charsets.UTF_8) => [
			write('''
				<html>
					<head>
				    	<link rel="stylesheet" href="./mdb/css/bootstrap.min.css">
				    	<link rel="stylesheet" href="./mdb/css/mdb.min.css">
				    	<link rel="stylesheet" href="./mdb/css/style.css">
				    	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
				    	<script type="text/javascript" src="./js/navbar.js"></script>
					</head>
					<body>
						<hr>
						<div class="container">
							«generateNavbar»
							<div id="content"/>
						</div>
					</body>
				</html>
			''')
			close
		]
	}
	
	def generateWollokDocFile(WFile file, File mainFile) {
		val lastUpdated = "Last update: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"))
		file => [
			allFiles.add(mainFile)
			val htmlFile = mainFile.name.toHtmlFile
			wollokDocFile = Files.newWriter(new File(outputFolder + File.separator + htmlFile), Charsets.UTF_8) => [
				write('''
				<hr>
				<div class="container">
					<p class="mx-auto">«lastUpdated»</p>
					<hr>
				''')
			]
			elements.forEach [ generateWollokDoc ]
			wollokDocFile.write('''
					<p>«lastUpdated»</p>
				</div>
				''')
		]
		wollokDocFile.close
	}
	
	def String toHtmlFile(String fileName) {
		fileName.replace(WollokConstants.CLASS_OBJECTS_EXTENSION, "html")
	}
	
	def String generateNavbar() {
		'''
		<nav class="navbar navbar-expand-lg navbar-dark red darken-2">
			<a class="navbar-brand" href="#">
				<img src="../images/WollokLogo.png" height="50" alt="">
			</a>
	        <ul class="navbar-nav mr-auto">
	        	«allFiles.map [ file | file.generateLink ].join(" ")»
	        </ul>
		</nav>
		'''
	}
	
	def String generateLink(File file) {
		val libraryName = file.name.split("\\.").head
		'''
		<li class="nav-item" id="«libraryName»">
			<a class="nav-link" href="javascript:selectFile('«libraryName»')">«file.name» <span class="sr-only">(current)</span></a>
		</li>
		'''
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
		header(mc.imageName + SPACE + mc.name, mc.name)
		writeFile(showHierarchy(mc.parent))
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
			writeFile(TABLE_BODY_ON)
			mc.methods.forEach [ 
				writeFile(TABLE_ROW_ON)
				generateWollokDoc
				writeFile(TABLE_ROW_OFF)
			]
			writeFile(TABLE_BODY_OFF)
			writeFile(TABLE_OFF)
			writeInheritedMethods(mc)
		}
		writeFile(HORIZONTAL_LINE)
	}
	
	def String showHierarchy(WClass c) {
		if (c === null) return ""
		'''
		<ul>
			<li>inherits from «linkTo(c.name, c.file.URI.lastSegment)»</li>
			«showHierarchy(c.parent)»
		</ul>
		'''
	}
	
	def String linkTo(String name, String fileName) {
		'''
		<a href="«fileName.toHtmlFile»#«name»">«name»</a>
		'''
	}
	
	def String imageName(WMethodContainer container) {
		'''
		<img src="images/«container.abstractionName».png" height="24px" width="24px" title="«container.abstractionName»"/>
		'''
	}
	
	def void writeInheritedMethods(WMethodContainer mc) {
		val currentMc = mc.parent
		if (mc.parent === null) {
			return
		}
		val inheritedMethods = currentMc.methods.map [ messageName ].join(", ")
		card("Methods inherited from " + currentMc.name, inheritedMethods)
		writeInheritedMethods(currentMc)
	}

	def void showComment(EObject o) {
		val comment = o.comment
		if (comment !== null) {
			writeFile(PARAGRAPH_ON + SPACE + comment + PARAGRAPH_OFF)
		}
	}
	
	def void header(String text, String name) {
		writeFile(
		'''
		<h2 id="«name»">«text»</h2>
		''')
	}
	
	def void header2(String text) {
		writeFile(HEADER2_ON + SPACE + text + HEADER2_OFF)
	}
	
	def void header3(String text) {
		writeFile(HEADER3_ON + SPACE + text + HEADER3_OFF)
	}
	
	def void tableHeader(String... headers) {
		writeFile(TABLE_HEADING_CONF_ON)
		writeFile(TABLE_ROW_ON)
		headers.forEach [ writeFile(TABLE_HEADING_ON + it + TABLE_HEADING_OFF) ]
		writeFile(TABLE_ROW_OFF)
		writeFile(TABLE_HEADING_CONF_OFF)
	}

	def void card(String title, String description) {
		writeFile('''
		<div class="card card-body">
		    <h5 class="card-header blue-grey lighten-4">«title»</h5>
		    <p class="card-text">«description»</p>
		</div>
		''')
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
			WollokDocParser.this.generateWollokDocFile(file.parse(false), file)
		]
	}
	
	def void writeFile(String text) {
		wollokDocFile.append(text + System.lineSeparator)
	}
}