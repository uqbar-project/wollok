package org.uqbar.project.wollok.tests.sdk

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

/**
 * Nota de dodain
 * 
 * Estos métodos no fueron enteramente reemplazados por su versión en wollok-language
 * ya que validan parte de la implementación de image
 */
class ImageTest extends AbstractWollokParameterizedInterpreterTest {

	static def data() {
		WollokConventionExtensions.IMAGE_CONVENTIONS.asArguments
	}
	
	var image = '''"image.png"'''
	var gameboard = Gameboard.getInstance
	
	@BeforeEach
	def void init() {
		//this.convention = WollokConventionExtensions.IMAGE_CONVENTIONS.get(0) 
		gameboard.clear
	}
	
	
	@ParameterizedTest
	@MethodSource("data")
	def void imageCanBeAccessedByGetterMethod(String convention) {
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

	@ParameterizedTest
	@MethodSource("data")
	def void imageCanBeAccessedByProperty(String convention) {
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

	@ParameterizedTest
	@MethodSource("data")
	def void imageCannotBeAccessedByAttribute(String convention) {
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
