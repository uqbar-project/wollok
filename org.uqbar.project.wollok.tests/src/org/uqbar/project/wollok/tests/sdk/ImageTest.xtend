package org.uqbar.project.wollok.tests.sdk

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.Image
import org.junit.Before

/**
 * Nota de dodain
 * 
 * Estos métodos no fueron enteramente reemplazados por su versión en wollok-language
 * ya que validan parte de la implementación de image
 */
class ImageTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String convention

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		WollokConventionExtensions.IMAGE_CONVENTIONS.asParameters
	}

	var image = '''"image.png"'''
	var gameboard = Gameboard.getInstance

	@Before
	def void init() {
		gameboard.clear
	}
	
	@Test
	def void imageCanBeAccessedByGetterMethod() {
		'''
		import wollok.game.*
		
		object aVisual {
			method «convention»() = «image»
		}
		
		object otherVisual {
			method «convention»() = «image»
		}

		program p {
			new Position(x = 0, y = 0).drawElement(aVisual)
			new Position(x = 0, y = 0).drawElement(otherVisual)
		}'''.interpretPropagatingErrors
		
		validateImage
	}

	@Test
	def void imageCanBeAccessedByProperty() {
		'''
		import wollok.game.*
		
		object visual {
			var property «convention» = «image»
		}

		program p {
			new Position(x = 0, y = 0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		validateImage
	}

	@Test
	def void imageCannotBeAccessedByAttribute() {
		'''
		import wollok.game.*
		
		object visual {
			var «convention» = «image»
		}

		program p {
			new Position(x = 0, y = 0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		validateDefaultImage
	}

	@Test
	def void visualsWithoutImageDefaultIsAssigned() {
		'''
		import wollok.game.*
		
		object visual { }
		
		program p {
			new Position(x = 0, y = 0).drawElement(visual)
		}'''.interpretPropagatingErrors
		
		validateDefaultImage
	}
	
	def validateImage() {
		validateImage("image.png")
	}
	
	def validateDefaultImage() {
		validateImage("wko.png")
	}
	
	def validateImage(String path) {
		components.forEach[
			assertEquals(new Image(path), it.image)
		]
	}
	
	def components() {
		gameboard.components
	}
}
