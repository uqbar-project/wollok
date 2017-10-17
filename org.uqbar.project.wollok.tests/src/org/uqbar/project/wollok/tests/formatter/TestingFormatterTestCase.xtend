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

	// TEST METHODS
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

}
