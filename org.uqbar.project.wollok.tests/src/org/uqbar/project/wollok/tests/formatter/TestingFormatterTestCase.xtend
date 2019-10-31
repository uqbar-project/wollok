package org.uqbar.project.wollok.tests.formatter

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.junit.Test
import org.junit.runner.RunWith
import org.uqbar.project.wollok.tests.injectors.WollokTestInjectorProvider

/**
 * Tests wollok code formatter for tests and describes
 * 
 * @author dodain
 */
@RunWith(XtextRunner)
@InjectWith(WollokTestInjectorProvider)
class TestingFormatterTestCase extends AbstractWollokFormatterTestCase {

	// TEST METHODS
	@Test
	def void testConstantsFormatting() throws Exception {
		assertFormatting(
    	'''const a = new Sobreviviente()
    	
    	
    	const b = new Sobreviviente()
    	test "aSimpleTest"{              assert.that(true)           }''', '''
			const a = new Sobreviviente()
			
			const b = new Sobreviviente()

			test "aSimpleTest" {
				assert.that(true)
			}
		''')
	}
	
	
	@Test
	def void testSimpleTestFormatting() throws Exception {
		assertFormatting(
    	'''test "aSimpleTest"{              assert.that(true)           }''', '''
			test "aSimpleTest" {
				assert.that(true)
			}
		''')
	}

	@Test
	def void severalTestsSimplesTestFormatting() throws Exception {
		assertFormatting(
    	'''test "aSimpleTest" {
    				assert.that(true)
    			} test "secondTest"
    			
    	{
    			var text = "hola"
    			
    	assert.equals(4, text.length()       )		
    	assert.equals(4    -     0, (   -   4)   .   inverted()       )
    	}		
    			''', '''
			test "aSimpleTest" {
				assert.that(true)
			}
			
			test "secondTest" {
				var text = "hola"
				assert.equals(4, text.length())
				assert.equals(4 - 0, (-4).inverted())
			}
		''')
	}

	@Test
	def void testTestSeveralLinesFormatting() throws Exception {
		assertFormatting(
    	'''test "aSimpleTest"{assert.that(true) assert.notThat(false)
    	
    	const a = 1 assert.equals(  1 , a)
    	assert.equals(a, a)
    	}''', '''
			test "aSimpleTest" {
				assert.that(true)
				assert.notThat(false)
				const a = 1
				assert.equals(1, a)
				assert.equals(a, a)
			}
		''')
	}

	@Test
	def void testSimpleDescribeFormatting() throws Exception {
		assertFormatting(
    	'''describe            "group of tests" 
{ 


test "aSimpleTest"
{



assert.that(true)}}''', '''
			describe "group of tests" {
			
				test "aSimpleTest" {
					assert.that(true)
				}
			
			}
			
		''')
	}

	@Test
	def void testSimpleDescribeFormatting2() throws Exception {
		assertFormatting(
    	'''describe            "group of tests"{test "aSimpleTest"{assert.that(true)}}''', '''
			describe "group of tests" {
			
				test "aSimpleTest" {
					assert.that(true)
				}
			
			}
			
		''')
	}

	@Test
	def void testSimpleDescribeWithFixture() throws Exception {
		assertFormatting(
    	'''describe            "group of tests" 
{ 
	var a
fixture { a = 1 }

test "aSimpleTest"
{



assert.equals(1, a)}}''', '''
			describe "group of tests" {
			
				var a
			
				fixture {
					a = 1
				}
			
				test "aSimpleTest" {
					assert.equals(1, a)
				}
			
			}
			
		''')
	}

	@Test
	def void testSimpleDescribeWithFixtureSeveralLines() throws Exception {
		assertFormatting(
    	'''describe            "group of tests" 
{ 
	var a var b var c           = 3
fixture { a = 1 




 
 
b = "hola"
	        }

test "aSimpleTest"
{



assert.equals(1, a)


assert.equals(b.length() - 1, c)
}}


''', '''
			describe "group of tests" {
			
				var a
				var b
				var c = 3
			
				fixture {
					a = 1
					b = "hola"
				}
			
				test "aSimpleTest" {
					assert.equals(1, a)
					assert.equals(b.length() - 1, c)
				}
			
			}
			
		''')
	}

	@Test
	def void testDescribeWithObjectDefinition() throws Exception {
		assertFormatting(
    	'''object foo { method bar() = 1 }describe            "group of tests" 
{ 
	var a  
	= foo.bar()
	
test "aSimpleTest"
{



assert.equals(1, a)


}}


''', '''
			object foo {
			
				method bar() = 1
			
			}
			
			describe "group of tests" {
			
				var a = foo.bar()
			
				test "aSimpleTest" {
					assert.equals(1, a)
				}
			
			}
			
		''')
	}

	@Test
	def void testComplexFixtureDefinition() throws Exception {
		assertFormatting(
			'''
		import musicos.*
		
		describe "tests - entrega 1" {
		
		var cisne
			var laFamilia var presentacionLunaPark         var presentacionLaTrastienda
		
			fixture {
				cisne = new Cancion(312, "Hoy el viento se abrió quedó vacío el aire una vez más y el manantial brotó y nadie está aquí y puedo ver que solo estallan las hojas al brillar")
				laFamilia = new Cancion(264, "Quiero brindar por mi gente sencilla, por el amor brindo por la familia")
				presentacionLunaPark = new Presentacion()
				presentacionLunaPark.fecha(new Date(20, 4, 2017))
				presentacionLunaPark.lugar(lunaPark)
				presentacionLunaPark.agregarMusico(luisAlberto)
				presentacionLunaPark.agregarMusico(joaquin)
				presentacionLunaPark.agregarMusico(lucia)
				presentacionLaTrastienda = new Presentacion()
				presentacionLaTrastienda.fecha(new Date(15, 11, 2017))
				presentacionLaTrastienda.lugar(laTrastienda)    				presentacionLaTrastienda.agregarMusico(luisAlberto)
				presentacionLaTrastienda.agregarMusico(joaquin)
				presentacionLaTrastienda.agregarMusico(lucia)
			}
		
			test "habilidad de Joaquín en grupo" {
				assert.equals(25, joaquin.habilidad())
			}
		

}
		''',
			'''
				import musicos.*
				
				describe "tests - entrega 1" {
				
					var cisne
					var laFamilia
					var presentacionLunaPark
					var presentacionLaTrastienda
				
					fixture {
						cisne = new Cancion(312, "Hoy el viento se abrió quedó vacío el aire una vez más y el manantial brotó y nadie está aquí y puedo ver que solo estallan las hojas al brillar")
						laFamilia = new Cancion(264, "Quiero brindar por mi gente sencilla, por el amor brindo por la familia")
						presentacionLunaPark = new Presentacion()
						presentacionLunaPark.fecha(new Date(20, 4, 2017))
						presentacionLunaPark.lugar(lunaPark)
						presentacionLunaPark.agregarMusico(luisAlberto)
						presentacionLunaPark.agregarMusico(joaquin)
						presentacionLunaPark.agregarMusico(lucia)
						presentacionLaTrastienda = new Presentacion()
						presentacionLaTrastienda.fecha(new Date(15, 11, 2017))
						presentacionLaTrastienda.lugar(laTrastienda)
						presentacionLaTrastienda.agregarMusico(luisAlberto)
						presentacionLaTrastienda.agregarMusico(joaquin)
						presentacionLaTrastienda.agregarMusico(lucia)
					}
				
					test "habilidad de Joaquín en grupo" {
						assert.equals(25, joaquin.habilidad())
					}
				
				}
				
			'''
		)
	}

	@Test
	def void testUsingPreviousExpressions() {
		assertFormatting(
			'''
				test "La capacidad del Luna Park el 08 de agosot de 2017 es 9290" {
				
					var dia = new Date(08, 08, 2017)
				
				   	assert.equals(9290, lunaPark.capacidad(dia))
				}
				
				   
			''',
			'''
				test "La capacidad del Luna Park el 08 de agosot de 2017 es 9290" {
					var dia = new Date(08, 08, 2017)
					assert.equals(9290, lunaPark.capacidad(dia))
				}
			'''
		)
	}

	@Test
	def void testFixtureWithComplexDefinition() {
		assertFormatting(
			'''
describe "testDeMusicGuide" {

	// musicos
	var soledad
	var kike
	var lucia
	var joaquin
	// canciones
	const cisne = new Cancion("Cisne", 312, "Hoy el viento se abrio quedo vacio el aire una vez mas y el manantial broto y nadie esta aqui y puedo ver que solo estallan las hojas al brillar")
	const laFamilia = new Cancion("La Familia", 264, "Quiero brindar por mi gente sencilla, por el amor brindo por la familia")
	const almaDeDiamante = new Cancion("Alma de Diamante", 216, "Ven a mi con tu dulce luz alma de diamante. Y aunque el sol se nuble despues sos alma de diamante. Cielo o piel silencio o verdad sos alma de diamante. Por eso ven asi con la humanidad alma de diamante")
	const crisantemo = new Cancion("Crisantemo", 175, "Tocame junto a esta pared, yo quede por aqui...cuando no hubo mas luz...quiero mirar a traves de mi piel...Crisantemo, que se abrio...encuentra el camino hacia el cielo")
	const eres = new Cancion("Eres", 145, "Eres lo mejor que me paso en la vida, no tengo duda, no habra mas nada despues de ti. Eres lo que le dio brillo al dia a dia, y asi sera por siempre, no cambiara, hasta el final de mis dias")
	const corazonAmericano = new Cancion("Corazon Americano", 154, "Canta corazon, canta mas alto, que tu pena al fin se va marchando, el nuevo milenio ha de encontrarnos, junto corazon, como soiamos")
	const aliciaEnElPais = new Cancion("Cancion de Alicia en el pais", 510, "Quien sabe Alicia, este pais no estuvo hecho porque si. Te vas a ir, vas a salir pero te quedas, ¿donde más vas a ir? Y es que aqui, sabes el trabalenguas, trabalenguas, el asesino te asesina, y es mucho para ti. Se acabo ese juego que te hacia feliz")
	const remixLaFamilia = new Remix(laFamilia.nombre(), laFamilia.duracion(), laFamilia.letra())
	const mashupAlmaCrisantemo = new Mashup("nombre", "duracion", "letra", [ almaDeDiamante, crisantemo ])
	// albumes
	const paraLosArboles = new Album("Para los arboles", new Date(31, 3, 2003), 50000, 49000).agregarCancion(cisne).agregarCancion(almaDeDiamante)
	const justCrisantemo = new Album("Just Crisantemo", new Date(05, 12, 2007), 28000, 27500).agregarCancion(crisantemo)
	const especialLaFamilia = new Album("Especial La Familia", new Date(17, 06, 1992), 100000, 89000).agregarCancion(laFamilia)
	const laSole = new Album("La Sole", new Date(04, 02, 2005), 200000, 130000).agregarCancion(eres).agregarCancion(corazonAmericano)
	// presentaciones
	var presentacionEnLuna
	var presentacionEnTrastienda
	// guitarras
	const fender = new Guitarra()
	const gibson = new Gibson()

	fixture {
		soledad = new VocalistaPopular().habilidad(55).palabraBienInterpretada("amor").agregarAlbum(laSole).agregarCancionDeSuAutoria(eres).agregarCancionDeSuAutoria(corazonAmericano)
		kike = new MusicoDeGrupo().habilidad(60).plusPorCantarEnGrupo(20)
		lucia = new VocalistaPopular().habilidad(70).palabraBienInterpretada("familia").grupo("Pimpinela")
		joaquin = new MusicoDeGrupo().habilidad(20).plusPorCantarEnGrupo(5).grupo("Pimpinela").agregarAlbum(especialLaFamilia).agregarCancionDeSuAutoria(laFamilia)
		luisAlberto.agregarGuitarra(fender).agregarGuitarra(gibson).agregarAlbum(paraLosArboles).agregarAlbum(justCrisantemo).agregarCancionDeSuAutoria(cisne).agregarCancionDeSuAutoria(almaDeDiamante).agregarCancionDeSuAutoria(crisantemo).cambiarGuitarraActiva(gibson)
		presentacionEnLuna = new Presentacion(lunaPark, new Date(20, 04, 2017), [ joaquin, lucia, luisAlberto ])
		presentacionEnTrastienda = new Presentacion(laTrastienda, new Date(15, 11, 2017), [ joaquin, lucia, luisAlberto ])
		pdpalooza.lugar(lunaPark).fecha(new Date(15, 12, 2017))
		restriccionPuedeCantarCancion.parametroRestrictivo(aliciaEnElPais)
	}
	
	test "fake" { assert.that(true) }
	}			
			''',
			'''
				describe "testDeMusicGuide" {
				
					// musicos
					var soledad
					var kike
					var lucia
					var joaquin
					// canciones
					const cisne = new Cancion("Cisne", 312, "Hoy el viento se abrio quedo vacio el aire una vez mas y el manantial broto y nadie esta aqui y puedo ver que solo estallan las hojas al brillar")
					const laFamilia = new Cancion("La Familia", 264, "Quiero brindar por mi gente sencilla, por el amor brindo por la familia")
					const almaDeDiamante = new Cancion("Alma de Diamante", 216, "Ven a mi con tu dulce luz alma de diamante. Y aunque el sol se nuble despues sos alma de diamante. Cielo o piel silencio o verdad sos alma de diamante. Por eso ven asi con la humanidad alma de diamante")
					const crisantemo = new Cancion("Crisantemo", 175, "Tocame junto a esta pared, yo quede por aqui...cuando no hubo mas luz...quiero mirar a traves de mi piel...Crisantemo, que se abrio...encuentra el camino hacia el cielo")
					const eres = new Cancion("Eres", 145, "Eres lo mejor que me paso en la vida, no tengo duda, no habra mas nada despues de ti. Eres lo que le dio brillo al dia a dia, y asi sera por siempre, no cambiara, hasta el final de mis dias")
					const corazonAmericano = new Cancion("Corazon Americano", 154, "Canta corazon, canta mas alto, que tu pena al fin se va marchando, el nuevo milenio ha de encontrarnos, junto corazon, como soiamos")
					const aliciaEnElPais = new Cancion("Cancion de Alicia en el pais", 510, "Quien sabe Alicia, este pais no estuvo hecho porque si. Te vas a ir, vas a salir pero te quedas, ¿donde más vas a ir? Y es que aqui, sabes el trabalenguas, trabalenguas, el asesino te asesina, y es mucho para ti. Se acabo ese juego que te hacia feliz")
					const remixLaFamilia = new Remix(laFamilia.nombre(), laFamilia.duracion(), laFamilia.letra())
					const mashupAlmaCrisantemo = new Mashup("nombre", "duracion", "letra", [ almaDeDiamante, crisantemo ])
					// albumes
					const paraLosArboles = new Album("Para los arboles", new Date(31, 3, 2003), 50000, 49000).agregarCancion(cisne).agregarCancion(almaDeDiamante)
					const justCrisantemo = new Album("Just Crisantemo", new Date(05, 12, 2007), 28000, 27500).agregarCancion(crisantemo)
					const especialLaFamilia = new Album("Especial La Familia", new Date(17, 06, 1992), 100000, 89000).agregarCancion(laFamilia)
					const laSole = new Album("La Sole", new Date(04, 02, 2005), 200000, 130000).agregarCancion(eres).agregarCancion(corazonAmericano)
					// presentaciones
					var presentacionEnLuna
					var presentacionEnTrastienda
					// guitarras
					const fender = new Guitarra()
					const gibson = new Gibson()
				
					fixture {
						soledad = new VocalistaPopular().habilidad(55).palabraBienInterpretada("amor").agregarAlbum(laSole).agregarCancionDeSuAutoria(eres).agregarCancionDeSuAutoria(corazonAmericano)
						kike = new MusicoDeGrupo().habilidad(60).plusPorCantarEnGrupo(20)
						lucia = new VocalistaPopular().habilidad(70).palabraBienInterpretada("familia").grupo("Pimpinela")
						joaquin = new MusicoDeGrupo().habilidad(20).plusPorCantarEnGrupo(5).grupo("Pimpinela").agregarAlbum(especialLaFamilia).agregarCancionDeSuAutoria(laFamilia)
						luisAlberto.agregarGuitarra(fender).agregarGuitarra(gibson).agregarAlbum(paraLosArboles).agregarAlbum(justCrisantemo).agregarCancionDeSuAutoria(cisne).agregarCancionDeSuAutoria(almaDeDiamante).agregarCancionDeSuAutoria(crisantemo).cambiarGuitarraActiva(gibson)
						presentacionEnLuna = new Presentacion(lunaPark, new Date(20, 04, 2017), [ joaquin, lucia, luisAlberto ])
						presentacionEnTrastienda = new Presentacion(laTrastienda, new Date(15, 11, 2017), [ joaquin, lucia, luisAlberto ])
						pdpalooza.lugar(lunaPark).fecha(new Date(15, 12, 2017))
						restriccionPuedeCantarCancion.parametroRestrictivo(aliciaEnElPais)
					}
				
					test "fake" {
						assert.that(true)
					}
				
				}
				
			'''
		)

	}
	
	@Test
	def void testDescribeWithMethodDefinition() throws Exception {
		assertFormatting(
    	'''describe "group of tests"              
    	
    	
    	
    	
    	{ method bar() = 1
    	
    	
    	
    	
    	
    	
    	method bar2() {
    		
    		
    		
    		
    		
    		
    		
    		
    		
    		return 1} test "aSimpleTest"
{



assert.equals(       self.bar(), 
           self.bar2())


}}


''', 
    	'''
		describe "group of tests" {
		
			method bar() = 1
		
			method bar2() {
				return 1
			}
		
			test "aSimpleTest" {
				assert.equals(self.bar(), self.bar2())
			}
		
		}
		
		''')
	}
	
}
