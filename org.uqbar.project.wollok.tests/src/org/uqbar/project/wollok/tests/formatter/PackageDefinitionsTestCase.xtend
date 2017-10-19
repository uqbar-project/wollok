package org.uqbar.project.wollok.tests.formatter

import org.junit.Test

class PackageDefinitionsTestCase extends AbstractWollokFormatterTestCase {

	@Test
	def void testBasicPackageDefinition() {
		assertFormatting(
			'''
			package           aves        
			
			
			{
          object        pepita     { var energia = 0  method volar() { energia    +=
10 }          
		}''',
			'''
			package aves {
			
				object pepita {

					var energia = 0

					method volar() {
						energia += 10
					}

				}
			
			}
			
			'''
		)
	}

}
