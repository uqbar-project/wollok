package org.uqbar.project.wollok.tests.libraries

import org.junit.Test
import org.uqbar.project.wollok.libraries.WollokLibExtensions
import org.junit.rules.TestName
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertFalse
class WollokLibExtensionsTest  {
	
	public static class IsCoreLibTest{
		@Test()
		def void whenPassALangFqnResponseTrue() {
			val String exceptionFqn = "wollok.lang.Exception"
			assertTrue(WollokLibExtensions.isCoreLib(exceptionFqn))
		}
		
		@Test()
		def void whenPassALibFqnResponseTrue() {
			val String libFqn = "wollok.lib"
			assertTrue(WollokLibExtensions.isCoreLib(libFqn))
		}
		
		@Test()
		def void whenPassANullResponseFalse() {
			assertFalse(WollokLibExtensions.isCoreLib(null))
		}
		@Test()
		def void whenPassAFqnIsNotCoreLibResponseFalse() {
			val String randomFqn = "randomfqn.aClass"
			assertFalse(WollokLibExtensions.isCoreLib(randomFqn))
		}
	}
	
}
