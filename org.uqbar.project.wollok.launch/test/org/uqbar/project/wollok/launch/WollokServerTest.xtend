package org.uqbar.project.wollok.launch

import com.google.gson.Gson
import org.eclipse.jetty.client.HttpClient
import org.eclipse.jetty.client.util.StringContentProvider
import org.eclipse.jetty.http.HttpMethod
import org.eclipse.jetty.util.ssl.SslContextFactory
import org.junit.BeforeClass
import org.junit.Test

import static org.junit.Assert.*
import org.junit.AfterClass

class WollokServerTest {
	extension Gson = new Gson
	static var HttpClient httpClient
		
	@Test 
	def void testServerConsole() {
		'''
			object pepita {
			    var energia = 100
			    method energia() = energia
			}
			
			program prueba {
			    console.println(pepita.energia())
			}
		'''.sendAndValidate [
			assertEquals('100\n', consoleOutput)
		]
	}
	
	@Test
	def void testCompilationIssues() {		
		'''
			object pepita {
			    var energia = 100
			}
			
			program prueba {
			    console.println(pepita.energia())
			}			
		'''
		.sendAndValidate [
			assertEquals(2, compilation.issues.length)
			compilation.issues.get(0) => [
				assertEquals("WARNING", severity)
				assertEquals("WARNING_UNUSED_VARIABLE", code)
				assertEquals("Unused variable", message)
				assertEquals(2, lineNumber)
				assertEquals(24, offset)
				assertEquals(7, length)
			]
			compilation.issues.get(1) => [
				assertEquals("ERROR", severity)
				assertEquals("METHOD_ON_WKO_DOESNT_EXIST", code)
				assertEquals("Method does not exist in well-known object", message)
				assertEquals(6, lineNumber)
				assertEquals(85, offset)
				assertEquals(7, length)
			]
		]
	}

	@Test
	def void testRuntimeError() {		
		'''
			class Golondrina {}
			
			program prueba {
			    new Golondrina().volar()
			    console.println("Should not be printed")
			}			
		'''
		.sendAndValidate [
//			println(runtimeErrors)
		]
	}

	// ************************************************************************
	// ** Utilities
	// ************************************************************************

	@BeforeClass
	def static void initClient() {
		httpClient = new HttpClient(new SslContextFactory) => [
			followRedirects = false
			start
		]
	}

	@AfterClass
	def static void cleanup() {
		httpClient = null
	}

	def sendAndValidate(CharSequence program, (WollokServerResponse)=>void validation) {
		httpClient.newRequest("http://localhost:8080/run") => [
			method(HttpMethod.POST)
			accept("application/json")
			content(new StringContentProvider(program.toString), "application/json")
			
			send => [
				println(contentAsString)
				val content = contentAsString.fromJson(WollokServerResponse)
				content => validation
			]
		]
		
	}
}
