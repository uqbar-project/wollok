package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
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

	@Test
	def void testBasicImportDefinition() {
		assertFormatting(
			'''
			import 
			
			 pepita.*
			import    wollok.game.*
			import archivo.* program abc {
				game.addVisual(pepita)
				game.start()
				pepita.come(5000)
				pepita.vola(10)
				pepita.vola(10)
				pepita.vola(10) pepita.vola(10)
			}
		''',
		'''
		import pepita.*
		import wollok.game.*
		import archivo.*
		
		program abc {
			game.addVisual(pepita)
			game.start()
			pepita.come(5000)
			pepita.vola(10)
			pepita.vola(10)
			pepita.vola(10)
			pepita.vola(10)
		}
		'''
		)
	}

}
