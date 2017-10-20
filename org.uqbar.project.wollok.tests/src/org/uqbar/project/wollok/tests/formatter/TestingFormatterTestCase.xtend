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
	def void testSimpleTestFormatting() throws Exception {
		assertFormatting(
    	'''test "aSimpleTest"{              assert.that(true)           }''', 
    	'''
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
    			''', 
    	'''
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
    	}''', 
    	'''
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



assert.that(true)}}''', 
    	'''
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
    	'''describe            "group of tests"{test "aSimpleTest"{assert.that(true)}}''', 
    	'''
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



assert.equals(1, a)}}''', 
    	'''
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


''', 
    	'''
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


''', 
    	'''
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
	
}
