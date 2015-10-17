package org.uqbar.project.wollok.ui.console.highlight

import com.google.inject.Inject
import java.io.ByteArrayInputStream
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.swt.SWT
import org.eclipse.swt.custom.LineStyleEvent
import org.eclipse.swt.custom.LineStyleListener
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.custom.StyledText
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator
import org.eclipse.xtext.ui.editor.syntaxcoloring.TextAttributeProvider
import org.uqbar.project.wollok.WollokConstants
import org.uqbar.project.wollok.ui.launch.Activator

import static extension org.uqbar.project.wollok.ui.quickfix.QuickFixUtils.*

/**
 * A line style listener for the console to highlight code
 * based on xtext infrastructure.
 * 
 * @author jfernandes
 */
class WollokCodeHighLightLineStyleListener implements LineStyleListener {
	val static PROMPT = ">>> " // duplicated from WollokRepl
	val static PROMPT_REPLACEMENT = "    "
	
	val static PROMPT_ANSI = "\u001b[36m>>> [m"
	
	var PARSER_ERROR_COLOR = new Color(null, new RGB(255, 0, 0))
	
	val programHeader = "program repl {\n"
	val programFooter =  "\n}"
	
	@Inject ISemanticHighlightingCalculator calculator
	@Inject TextAttributeProvider stylesProvider
	@Inject XtextResourceSet resourceSet
	
	new() {
		Activator.getDefault.injector.injectMembers(this)
	}
	
	override lineGetStyle(LineStyleEvent event) {
		if (event == null || event.lineText == null || event.lineText.length == 0 || !event.isCodeInputLine)
            return;
            
        val originalText = (event.widget as StyledText).text
		val escaped = escape(event.lineText)

		val resource = parseIt(programHeader + escaped + programFooter)

		val footerOffset = programHeader.length + escaped.length
		val headerLength = programHeader.length		

		// first styles are parser errors		
		val styles = resource.parseResult.syntaxErrors
							.filter[offset > programHeader.length && offset < footerOffset]
							.map[ parserError(event, offset, Math.min(length, footerOffset)) ]
							.toList
		
		// add highlights
		calculator.provideHighlightingFor(resource) [ offset, length, styleIds |
			val styleId = styleIds.get(0) // just get the first one ??
			val style = stylesProvider.getAttribute(styleId)
			
			val s = new StyleRange(event.lineOffset + offset - headerLength, length, style.foreground, style.background)
			s.data = styleId
			
			if (s.start <= originalText.length && (s.start + s.length) <= originalText.length) {
				styles.add(s)
			}
		]
		
		// try to imitate some styles as the editor
		
		resource.contents.get(0).node.asTreeIterable
			.filter[offset > programHeader.length && offset < footerOffset]
			.forEach [n | processASTNode(styles, n, n.grammarElement, event, headerLength) ]
		
//		println("APPLYED " + styles.size + " STYLES")
		
		if (!styles.empty) {
			if (!event.styles.empty)
				styles.addAll(event.styles)
			event.styles = styles.mixin
		}
		
		safelyPrintStyles(event, originalText)
	}
	
	var KEYWORD_COLOR = new Color(null, new RGB(127, 0, 85))
	
	def dispatch processASTNode(List<StyleRange> styles, INode n, Keyword it, LineStyleEvent event, int headerLength) { 
		if (value.length > 1) {
			val s = new StyleRange(event.lineOffset + n.offset - headerLength, n.length, KEYWORD_COLOR, null)
			s.data = "KEYWORD"
			styles.add(s)
		}
	}
	def dispatch processASTNode(List<StyleRange> styles, INode n, EObject it, LineStyleEvent event, int headerLength) { }
	def dispatch processASTNode(List<StyleRange> styles, INode n, Void it, LineStyleEvent event, int headerLength) { }
	
	def parseIt(String content) {
		new XtextResource => [
			URI = computeUnusedUri 
			Activator.getDefault.injector.injectMembers(it)
			load(new ByteArrayInputStream(content.bytes), #{})			
		]
	}
	
	def parserError(LineStyleEvent event, int offset, int length) {
		new StyleRange(event.lineOffset + (offset - programHeader.length), length, PARSER_ERROR_COLOR, null, SWT.ITALIC) => [
			data = "PARSER_ERROR"
		]
	}
	
	def mixin(List<StyleRange> ranges) {
		// remove 0 length
		val sorted = ranges.filter[length > 0].sortBy[start]
		sorted.forEach[s |
			val nextOnes = sorted.filter[start > s.start].sortBy[start]
			val colliding = nextOnes.findFirst[start <= (s.start + s.length) ]
			// cut it
			if (colliding != null)
				s.length = colliding.start - s.start
		]
		sorted
	}
	
	def static escape(String text) {
		var escaped = text
		val matcher = WollokAnsiColorLineStyleListener.pattern.matcher(text)
		while (matcher.find) {
            val start = matcher.start
            val end = matcher.end
            escaped = escaped.substring(0, start) + (' ' * (end - start)) + escaped.substring(end)
		}
		
		escaped.replaceAll(PROMPT, PROMPT_REPLACEMENT)
	}
	
	def static operator_multiply(String s, int n) { (1..n).map[' '].join }
	
	def isCodeInputLine(LineStyleEvent it) { lineText.startsWith(PROMPT) || lineText.startsWith(PROMPT_ANSI) }
	
	def computeUnusedUri() {
		val name = "__repl_synthetic"
		var i = 0
		while(i < Integer.MAX_VALUE) {
			val syntheticUri = URI.createURI(name + i + "." + WollokConstants.PROGRAM_EXTENSION);
			if (resourceSet.getResource(syntheticUri, false) == null)
				return syntheticUri
			i++
		}
		throw new IllegalStateException
	}
	
	protected def safelyPrintStyles(LineStyleEvent event, String originalText) {
		if (!event.styles.empty) {
			event.styles.filter[it != null].sortBy[start].toList.forEach[
				try {
					println('''[«start»,«start + length», «data», "«originalText.substring(start, start + length)»"]''')
				}
				catch (StringIndexOutOfBoundsException e) {
					println('''//////////////// BOOM !: text size «originalText.length» and OFFENDING STYLE: «it»''')
				}
			]
		}
	}
}