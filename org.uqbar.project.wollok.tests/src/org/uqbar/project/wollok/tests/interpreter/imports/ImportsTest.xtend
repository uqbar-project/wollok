package org.uqbar.project.wollok.tests.interpreter.imports

import org.uqbar.project.wollok.tests.interpreter.AbstractWollokInterpreterTestCase
import org.junit.Test
import org.junit.Ignore

/**
 * Test the different combinations and functionality of imports.
 * 
 * @author jfernandes
 * @author tesonep
 * 
 */
class ImportsTest extends AbstractWollokInterpreterTestCase {
	
	@Test
	def void testImportObject() {
		#['aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			
		''',
		'entrenador' -> '''
			import aves.*
			
			object mostaza {
				method entrenar() {
					return pepita.getNombre()
				} 
			}
		''',
		'programa' -> '''
			import entrenador.*
			program a {
				const nombre = mostaza.entrenar()
				
				assert.equals('pepita', nombre)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testImportObjectMultiLevel() {
		#['model/aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			
		''',
		'model/entrenador' -> '''
			import model.aves.*
			
			object mostaza {
				method entrenar() {
					return pepita.getNombre()
				} 
			}
		''',
		'pgm/programa' -> '''
			import model.entrenador.*
			program a {
				const nombre = mostaza.entrenar()
				
				assert.equals('pepita', nombre)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}

	@Test
	def void testImportObjectMultiLevelRelative() {
		#['model/aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			
		''',
		'model/entrenador' -> '''
			import aves.*
			
			object mostaza {
				method entrenar() {
					return pepita.getNombre()
				} 
			}
		''',
		'pgm/programa' -> '''
			import model.entrenador.*
			program a {
				const nombre = mostaza.entrenar()
				
				assert.equals('pepita', nombre)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}


	@Test
	def void testImportObjectInSrc() {
		#['src/model/aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			
		''',
		'src/model/entrenador' -> '''
			import aves.*
			
			object mostaza {
				method entrenar() {
					return pepita.getNombre()
				} 
			}
		''',
		'src/pgm/programa' -> '''
			import model.entrenador.*
			program a {
				const nombre = mostaza.entrenar()
				
				assert.equals('pepita', nombre)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}

	
	@Test
	def void testMultipleObjectsImports() {
		#['aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			object pepona {
				method getNombre() = "pepona"
			}
		''',
		'entrenador' -> '''
			import aves.pepita
			import aves.pepona
			
			object mostaza {
				method entrenar() {
					return [pepita, pepona].map{p => p.getNombre()}.join(',')
				} 
			}
		''',
		'programa' -> '''
			import entrenador.mostaza
			program a {
				const nombre = mostaza.entrenar()
				
				assert.equals('pepita,pepona', nombre)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testMultipleObjectsImportsWithWildcard() {
		#['aves' -> '''
			object pepita {
				method getNombre() = "pepita"
			}
			object pepona {
				method getNombre() = "pepona"
			}
		''',
		'programa' -> '''
			import aves.*
			program a {
				assert.equals('pepita,pepona', [pepita, pepona].map{p => p.getNombre()}.join())
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testImportWithPackage() {
		#['aves' -> '''
			package nadadoras {
				object patitoFeo {
					method getNombre() = "Patito Feo"
				}	
			}
			
			object pepona {
				method getNombre() = "pepona"
			}
		''',
		'programa' -> '''
			import aves.nadadoras.patitoFeo
			import aves.pepona
			program a {
				assert.equals('Patito Feo', patitoFeo.getNombre())
				assert.equals('pepona', pepona.getNombre())
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void importWithPackages(){
		#["model/armas" -> '''
			package xxx {
			
				class Arma {
					method disparar() {
					}
				}
			}
			
			class Guerrero {
				
			}
		''',
		"test/test" -> '''
			import model.*
			import model.armas.*
			
			test "test con arma" {
				const arma = new armas.xxx.Arma()
				assert.that(true)
			}
			
			test "thor pelea duro" {
				const thor = new armas.Guerrero()
				const thor2 = new Guerrero()
				assert.that(true)	
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	@Ignore // No puedo armar una gramática válida que funcione. 
	def void mustUseFullNameToReferenceObjectFromSameFileButDifferentPackage() {
		'''
			package aves {
				object pepita {
					method volar() { "vuelo vuelo" }
				}	
			}
			package entrenadores {
				object mostaza {
					method entrenar() {
						aves.pepita.volar()        // NO DEBERIA FALLAR !: creo que no tenemos soporte en la gramática para hacer esto !
					}
				}	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void implicitObjectsAndClassesFromWollokSDKFromWithinAPackage() {
		'''
			package aves {
				object pepita {
					method volar() { 
						console.println('abc')
						const p = new Pair(x = 1, y = 2)
					}
				}	
			}
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void implicitClassesFromRootObjects() {
		'''
			object pepita {
				method volar() { 
					const p = new Pair(x = 1, y = 2)
				}
			}	
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void implicitObjectsFromRootObjects() {
		'''
			object pepita {
				method volar() { 
					console.println("sarasa")
				}
			}	
		'''.interpretPropagatingErrors
	}
	
	@Test
	def void testUseFullClassNameWithFile() {
		#['aves' -> '''
			class Golondrina {
			}
		''',
		'programa' -> '''
			program a {
				assert.that(new aves.Golondrina() != null)
			}
		'''
		].interpretPropagatingErrors
	}
	
	@Test
	def void testImportClassNoPackage() {
		#['aves' -> '''
			class Golondrina {
			}
		''',
		'programa' -> '''
			import aves.Golondrina
			program a {
				assert.that(new Golondrina() != null)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testImportClassWithWildcardNoPackage() {
		#['aves' -> '''
			class Golondrina {
			}
		''',
		'programa' -> '''
			import aves.*
			program a {
				assert.that(new Golondrina() != null)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testImportClassWithPackage() {
		#['aves' -> '''
			package nadadoras {
				class Pato {
				}
			}
		''',
		'programa' -> '''
			import aves.nadadoras.Pato
			program a {
				assert.that(new Pato() != null)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testImportClassWithPackageAndWildcards() {
		#['aves' -> '''
			package nadadoras {
				class Pato {
				}
			}
		''',
		'programa' -> '''
			import aves.nadadoras.*
			program a {
				assert.that(new Pato() != null)
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testClassReferencesBetweenPackages() {
		#['aves' -> '''
			package nadadoras {
				class Pato {
				}
			}
			package voladoras {
				class Gorrion {
					method crearUnPato() {
						new nadadoras.Pato()
					}
				}
			}
		'''
		].interpretAsFilesPropagatingErrors
	}
	
	@Test
	def void testRefereceByFQNWithoutImport() {
		
		#[
		'b' -> '''
			class Golondrina  {
			    method volar(kms) {
			        console.println("flying...")
			    }
			}
		''',
		'programa' -> '''
			program zuper {
			        const pepona = new b.Golondrina()
			}
		'''
		].interpretAsFilesPropagatingErrors
	}

	@Test
	def void missingImportIssue1399() {
		'''
		describe "Cuenta" {
			test "depositar monto" {
				assert.throwsExceptionWithMessage("Couldn't resolve reference to Cuenta", {
					const cuenta = new Cuenta()
					cuenta.depositar()
				}
			}
		}
		'''.interpretPropagatingErrorsWithoutStaticChecks
	}
	
}
