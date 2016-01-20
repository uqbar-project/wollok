package org.uqbar.project.wollok.tests.game

import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.lib.WollokConventionExtensions
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

class ImageTest extends AbstractWollokParameterizedInterpreterTest {
	@Parameter(0)
	public String convention

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		WollokConventionExtensions.IMAGE_CONVENTIONS.asParameters
	}

	@Test
	def void imageCanBeAccessedByGetterMethod() {
		'''
		program p {
			var aVisual = object {
				method get«convention.toFirstUpper»() = "image.png"
			}
			
			var otherVisual = object {
				method «convention»() = "image.png"
			}
		
			new Position(0,0).drawElement(aVisual)
			new Position(0,0).drawElement(otherVisual)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void imageCanBeAccessedByProperty() {
		'''
		program p {
			var visual = object {
				var «convention» = "image.png"
			}
		
			new Position(0,0).drawElement(visual)
		}'''.interpretPropagatingErrors
	}

	@Test
	def void visualsWithoutImageCantBeRendered() {
		try {
			'''
			object visual { }
			
			program p {
				new Position(0,0).drawElement(visual)
			}'''.interpretPropagatingErrors
		} catch (AssertionError exception) {
			assertTrue(exception.message.contains("Visual object doesn't have any position"))
		}
	}
}
