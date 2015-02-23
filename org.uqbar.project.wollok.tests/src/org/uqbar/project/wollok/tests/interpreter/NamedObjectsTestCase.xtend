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
						energy
					}
					
					method addEnergy(amount){
						energy = energy + amount
					}
				}
			''',
			'''
				program namedObjects{
					this.assertEquals(0, pepita.energyLevel())
					pepita.addEnergy(10)
					this.assertEquals(10, pepita.energyLevel())
				}
			'''
		].interpretPropagatingErrors
	}

}
