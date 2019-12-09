package org.uqbar.project.wollok.tests.libraries

import org.uqbar.project.wollok.libraries.WollokLibExtensions

import static org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

class WollokLibExtensionsTest {

	static class IsCoreLibTest {

		@Test()
		def void libFQNisACoreLibrary() {
			val String exceptionFqn = "wollok.lang.Exception"
			assertTrue(WollokLibExtensions.isCoreLib(exceptionFqn))
		}

		@Test()
		def void langFQNisACoreLibrary() {
			val String libFqn = "wollok.lib"
			assertTrue(WollokLibExtensions.isCoreLib(libFqn))
		}

		@Test()
		def void nullIsNotACoreLibrary() {
			assertFalse(WollokLibExtensions.isCoreLib(null))
		}

		@Test()
		def void customClassIsNotACoreLibrary() {
			val String randomFqn = "randomfqn.aClass"
			assertFalse(WollokLibExtensions.isCoreLib(randomFqn))
		}

	}

}
