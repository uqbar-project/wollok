package org.uqbar.project.wollok.tests.wollokDoc

import org.uqbar.project.wollok.wollokDoc.WollokDocParser
import org.junit.Test
import java.io.File
import com.google.common.base.Charsets
import com.google.common.io.Files
import java.time.LocalDateTime
import java.time.Month
import org.junit.rules.TemporaryFolder
import org.junit.Rule
import org.junit.Assert
import java.util.function.BiConsumer

class WollokDocParserTest extends Assert {
	@Rule
	public TemporaryFolder folder = new TemporaryFolder();

	@Test
	def void uses_comments_for_objects_and_methods_in_the_wollok_file_to_generate_html_docs() {
		val documentation = generateDocsForWollokFileWithContents('''
			/** 
			 * Console is a global wollok object that implements a character-based console device
			 * called "standard input/output" stream 
			 */
			object console {
			
			  /** Prints a String with end-of-line character */
			  method println(obj) native
			  
			  /** Reads a line from input stream */
			  method readLine() native
			  
			  /** Reads an int character from input stream */
			  method readInt() native
			  
			  /** Returns the system's representation of a new line:
			   * - \n in Unix systems
			   * - \r\n in Windows systems
			   */
			  method newline() native
			}
		''',
		LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0))

		documentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;Console is a global wollok object that implements a character-based console device<br>called "standard input/output" stream</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_newline_0"><code><b>newline</b>()</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Returns the system's representation of a new line:<br>- \n in Unix systems<br>- \r\n in Windows systems</td>
			</tr>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Prints a String with end-of-line character</td>
			</tr>
			<tr>
			<td title="console" width="30%" id="console_readInt_0"><code><b>readInt</b>()</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Reads an int character from input stream</td>
			</tr>
			<tr>
			<td title="console" width="30%" id="console_readLine_0"><code><b>readLine</b>()</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Reads a line from input stream</td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
		''')
	}
	
	@Test
	def void when_generating_doc_in_a_language_and_comments_are_present_in_that_language_uses_them_to_generate_the_docs() {
		val exampleWlk = '''
			/** 
			 * lang: en
			 * Console is a global wollok object that implements a character-based console device
			 * called "standard input/output" stream
			 * ---
			 * lang: es
			 * console es un objeto global de wollok que implementa una consola de entrada/salida 
			 */
			object console {
			
			  /**
			   * lang: en
			   * Prints a String with end-of-line character
			   * ---
			   * lang: es
			   * Imprime un String seguido de un caracter de fin de linea
			   */
			  method println(obj) native
			}
		'''
		
		val spanishDocumentation = generateDocsForWollokFileWithContents(exampleWlk,
																  		 LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
																  		 "es")
		val englishDocumentation = generateDocsForWollokFileWithContents(exampleWlk,
																  		 LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
																  		 "en")

		spanishDocumentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;console es un objeto global de wollok que implementa una consola de entrada/salida</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Imprime un String seguido de un caracter de fin de linea</td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
		''')
		englishDocumentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;Console is a global wollok object that implements a character-based console device<br>called "standard input/output" stream</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Prints a String with end-of-line character</td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
		''')
	}
	
	@Test
	def void order_in_the_wollok_comment_does_not_matter_when_picking_the_correct_language_for_documentation() {
		val documentation = generateDocsForWollokFileWithContents('''
			/** 
			 * lang: es
			 * console es un objeto global de wollok que implementa una consola de entrada/salida
			 * ---
			 * lang: en
			 * Console is a global wollok object that implements a character-based console device
			 * called "standard input/output" stream
			 */
			object console {
			
			  /**
			   * lang: en
			   * Prints a String with end-of-line character
			   * ---
			   * lang: es
			   * Imprime un String seguido de un caracter de fin de linea
			   */
			  method println(obj) native
			}
			''',
			LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
			"es")

		documentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;console es un objeto global de wollok que implementa una consola de entrada/salida</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Imprime un String seguido de un caracter de fin de linea</td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
		''')
	}
	
	@Test
	def void when_there_are_no_wlk_comments_for_the_language_it_does_not_show_description_for_those_fields() {
		val documentation = generateDocsForWollokFileWithContents('''
			/** 
			 * lang: es
			 * console es un objeto global de wollok que implementa una consola de entrada/salida
			 */
			object console {
			
			  /**
			   * lang: es
			   * Imprime un String seguido de un caracter de fin de linea
			   */
			  method println(obj) native
			}
			''',
			LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
			"en")

		documentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;"></td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
		''')
	}
	
	@Test
	def void not_having_wlk_comments_in_the_expected_language_works_the_same_as_not_having_wlk_comments() {
		val wollokFileWithoutComments = '''
			object console {

			  method println(obj) native
			}
			'''
		val wollokFileWithOnlySpanishComments = '''
			/** 
			 * lang: es
			 * console es un objeto global de wollok que implementa una consola de entrada/salida
			 */
			object console {
			
			  /**
			   * lang: es
			   * Imprime un String seguido de un caracter de fin de linea
			   */
			  method println(obj) native
			}
			'''
		val docsForWollokFileWithoutComments = generateDocsForWollokFileWithContents(wollokFileWithoutComments,
										  											 LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
										  											 "en")
		val docsForWollokFileWithOnlySpanishComments = generateDocsForWollokFileWithContents(wollokFileWithOnlySpanishComments,
												  											 LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
												  											 "en")

		docsForWollokFileWithoutComments.assertEquals(docsForWollokFileWithOnlySpanishComments)
	}
	
	@Test
	def void when_a_field_has_a_non_localized_comment_it_is_used_for_all_language_in_the_docs() {
		val documentation = generateDocsForWollokFileWithContents('''
			/**
			 * Console is a global wollok object that implements a character-based console device
			 * called "standard input/output" stream
			 */
			object console {
			
			  /**
 			   * lang: en
			   * Prints a String with end-of-line character
			   * ---
			   * lang: es
			   * Imprime un String seguido de un caracter de fin de linea
			   */
			  method println(obj) native
			}
			''',
			LocalDateTime.of(2015, Month.OCTOBER, 21, 07, 28, 0),
			"es")
		
		documentation.assertSameStringAs('''
			<h2 id="console"><img src="images/object.png" height="24px" width="24px" title="object"/>
			&nbsp;console</h2>
			
			
			<p>&nbsp;Console is a global wollok object that implements a character-based console device<br>called "standard input/output" stream</p>
			<h3>&nbsp;Behavior</h3>
			<div class="container"><table class="table table-striped table-hover table-sm w-auto">
			<thead>
			<tr>
			<th class="blue-grey lighten-2">Method</th>
			<th class="blue-grey lighten-2">Description</th>
			</tr>
			</thread>
			<tbody>
			<tr>
			<td title="console" width="30%" id="console_println_1"><code><b>println</b>(obj)</code>&nbsp;&nbsp;&nbsp;<span class="badge badge-pill indigo">native</span><br>
			&nbsp;</td><td width="70%;">Imprime un String seguido de un caracter de fin de linea</td>
			</tr>
			</tbody>
			</table></div>
			<hr>
			<div class="container">
			</div>
			<p>Last update: 21/10/2015 07:28:00</p>
			''')
	}

	def generateDocsForWollokFileWithContents(String fileContent, BiConsumer<File, File> runWollokDocParser) {
		val libs = folder.newFolder()
		val docs = folder.newFolder()

		Files.newWriter(new File('''«libs.absolutePath»«File.separator»example.wlk'''), Charsets.UTF_8) => [
			write(fileContent)
			close
		]
		
		runWollokDocParser.accept(libs, docs)

		Files.asCharSource(new File('''«docs.absolutePath»«File.separator»example.html'''), Charsets.UTF_8).read()
	}

	def generateDocsForWollokFileWithContents(String fileContent, LocalDateTime timestamp, String locale) {
		generateDocsForWollokFileWithContents(fileContent, [ libs, docs |
			new WollokDocParser(timestamp).doMain(#[libs.absolutePath, "-folder", docs.absolutePath, "-locale", locale])
		])
	}

	def generateDocsForWollokFileWithContents(String fileContent, LocalDateTime timestamp) {
		generateDocsForWollokFileWithContents(fileContent, [ libs, docs |
			new WollokDocParser(timestamp).doMain(#[libs.absolutePath, "-folder", docs.absolutePath])
		])
	}

	def void assertSameStringAs(CharSequence actual, CharSequence expected) {
		(expected.toString).assertEquals(actual.toString)
	}

}
