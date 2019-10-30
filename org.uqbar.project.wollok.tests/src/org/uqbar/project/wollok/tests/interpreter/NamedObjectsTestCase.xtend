package org.uqbar.project.wollok.tests.interpreter

import org.junit.Test

class NamedObjectsTestCase extends AbstractWollokInterpreterTestCase {
	@Test
	def void effects() {
		#[
			'''
				object pepita {
					var energy = 0
					method energyLevel(){
						return energy
					}
					
					method addEnergy(amount){
						energy = energy + amount
					}
				}

				program namedObjects{
					assert.equals(0, pepita.energyLevel())
					pepita.addEnergy(10)
					assert.equals(10, pepita.energyLevel())
				}
			'''
		].interpretPropagatingErrors
	}

	@Test
	def unusedVariables() {
		val model = '''
			object pepita {
				var energia = 0
				method getEnergia(){ return energia }
				method setEnergia(x){ energia = x }
			}
		'''.parse

		model.assertNoIssues
	}

	@Test
	def void usingSelf() {
		'''
			object pepita {
				method uno(){
					return self.otro()
				}
				method otro(){
					return 5
				}
			}
		'''.interpretPropagatingErrors
	}

}
