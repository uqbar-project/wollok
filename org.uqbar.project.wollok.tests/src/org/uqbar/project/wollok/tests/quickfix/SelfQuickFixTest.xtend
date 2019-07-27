package org.uqbar.project.wollok.tests.quickfix

import org.junit.Test
import org.uqbar.project.wollok.ui.Messages

class SelfQuickFixTest extends AbstractWollokQuickFixTestCase {

	@Test
	def replaceWkoNameWithSelf(){
		val initial = #['''
			object pepita {
				var energia = 0
				
			    method volar(kms) {
			        pepita.reducirEnergia(kms * 10)
			    }
			
			   method reducirEnergia(cant) {
			       energia = (energia - cant).max(0)
			   }
			}
		''']

		val result = #['''
			object pepita {
				var energia = 0
				
			    method volar(kms) {
			        self.reducirEnergia(kms * 10)
			    }
			
			   method reducirEnergia(cant) {
			       energia = (energia - cant).max(0)
			   }
			}
		''']
		assertQuickfix(initial, result, Messages.WollokDslQuickFixProvider_replace_wkoname_with_self_name)		
	}

} 