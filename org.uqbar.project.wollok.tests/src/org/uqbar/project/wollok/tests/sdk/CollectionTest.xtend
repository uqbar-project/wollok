package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase

/**
 * 
 * @author tesonep
 * @author jfernandes
 */
class CollectionTest extends AbstractWollokInterpreterTestCase {

	@Test
	def void testCollectionAsInstanceVariable() { #['''
		object pajarera{
			const pajaros = []
			method agregar(unPajaro){
				pajaros.add(unPajaro)
			}
			method quitar(unPajaro){
				pajaros.remove(unPajaro)
			}
			method cantidad(){
				return pajaros.size()
			}
		}
		
		object pepita{
			
		}

		program p {
			pajarera.agregar(pepita)
			pajarera.quitar(pepita)
			assert.that(pajarera.cantidad() == 0)
		}'''].interpretPropagatingErrors
	}
	
	@Test
	def void test_issue_40() {
		'''
		object pajarera {
		    var energiaMenor = 100 
		    var pajaros = [pepita, pepe]
		    method menorValor(){
		        pajaros.forEach{a => a.sosMenor(energiaMenor)}
		        return energiaMenor
		    }      
		
		    method setEnergiaMenor(valor){
		        energiaMenor = valor
		    }
		}
		
		object pepe {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(10)
		    }
		}
		
		object pepita {
		    method sosMenor(energiaMenor){
		        pajarera.setEnergiaMenor(25)
		    }
		}
		program p {
			const menor = pajarera.menorValor()
			assert.equals(10, menor)
		}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testAddAll() { 
		'''
		program p {
			const unos = [1,2,3,4]
			const otros = [5,6,7,8]
			
			const todos = []
			todos.addAll(unos)
			todos.addAll(otros)			
			assert.equals(8, todos.size())
		}'''.interpretPropagatingErrors
	}

	@Test
	def void testFlatMap() {
		'''
		program p {
			assert.equals([1,2,3,4], [[1,2], [3,4]].flatten())
			assert.equals([1,2,3,4], [[1,2], [], [3,4]].flatten())
			assert.equals([], [].flatten())
			assert.equals([], [[]].flatten())
		}'''.interpretPropagatingErrors
	}
	
	@Test
	def void copyWithoutDontMutateTheCollection(){
		'''
		const unList = [1,2,3,4,5]
		const newList = unList.copyWithout(3)
		assert.equals(unList, [1,2,3,4,5])
		'''.test
	}
	
	@Test
	def void whenPassANumberAtCopyWithoutMethodReturnANewCollectionWithoutThisNumber() {
		'''
		const unList = [1,2,3,4,5]
		const newList = unList.copyWithout(3)
		assert.equals(newList, [1,2,4,5])
		'''.test
	}
	
	@Test
	def void whenPassAStringAtCopyWithoutMethodReturnANewCollectionWithoutThisString() {
		'''
		const unList = ["hola","como","estas"]
		const newList = unList.copyWithout("como")
		assert.equals(newList, ["hola","estas"])
		'''.test
	}
	
	@Test
	def void copyWithDontMutateTheCollection(){
		'''
		const unList = [1,2,3,4,5]
		const newList = unList.copyWith(3)
		assert.equals(unList, [1,2,3,4,5])
		'''.test
	}
	
	@Test
	def void whenPassANumberAtCopyWithMethodReturnANewCollectionWithThisNumber() {
		'''
		const unList = [1,2,3,4,5]
		const newList = unList.copyWith(6)
		assert.equals(newList, [1,2,3,4,5,6])
		'''.test
	}
	
	@Test
	def void whenPassAStringAtCopyWithMethodReturnANewCollectionWithThisString() {
		'''
		const unList = ["hola","como"]
		const newList = unList.copyWith("estas")
		assert.equals(newList, ["hola","como","estas"])
		'''.test
	}
	
}
