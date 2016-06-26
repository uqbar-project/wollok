package org.uqbar.project.wollok.launch

import org.eclipse.jetty.client.HttpClient
import org.eclipse.jetty.client.util.StringContentProvider
import org.eclipse.jetty.http.HttpMethod
import org.eclipse.jetty.util.ssl.SslContextFactory
import org.junit.Test
import com.google.gson.Gson
import static org.junit.Assert.*

class WollokServerTest {
	@Test
	def void testBasicServerTest() {
		val extension gson = new Gson
		
		// Instantiate and configure the SslContextFactory
		val sslContextFactory = new SslContextFactory()

		// Instantiate HttpClient with the SslContextFactory
		val httpClient = new HttpClient(sslContextFactory) => [
			followRedirects = false
			start
		]

		httpClient.newRequest("http://localhost:8080/run") => [
			method(HttpMethod.POST)
			accept("application/json")
			content(new StringContentProvider('''
				object pepita {
				    var energia = 100
				}
				
				program prueba {
				    console.println(pepita.energia())
				}			
			'''), "application/json")
			
			send => [
				val content = contentAsString.fromJson(WollokServerResponse)
				assertEquals(2, content.compilation.issues.length)
				
				content.compilation.issues.get(0) => [
					assertEquals("WARNING", severity)
					assertEquals("WARNING_UNUSED_VARIABLE", code)
					assertEquals("Unused variable", message)
					assertEquals(2, lineNumber)
					assertEquals(24, offset)
					assertEquals(7, length)
				]
				content.compilation.issues.get(1) => [
					assertEquals("ERROR", severity)
					assertEquals("METHOD_ON_WKO_DOESNT_EXIST", code)
					assertEquals("Method does not exist in well-known object", message)
					assertEquals(6, lineNumber)
					assertEquals(85, offset)
					assertEquals(7, length)
				]
			]
		]
		
	}

}
