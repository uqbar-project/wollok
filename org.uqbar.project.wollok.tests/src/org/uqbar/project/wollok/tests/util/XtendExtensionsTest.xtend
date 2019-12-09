package org.uqbar.project.wollok.tests.util

import org.junit.jupiter.api.Test
import org.uqbar.project.wollok.utils.XtendExtensions
import java.util.List
import org.junit.jupiter.api.Assertions

class XtendExtensionsTest extends Assertions {
	@Test
	def void testSubsetsOfSizeTrivial() {
		assertArrayOfArrayEquals(#[#[1, 2, 3]], XtendExtensions.subsetsOfSize(#[1, 2, 3], 3))
	}

	@Test
	def void testSubsetsOfSizeUnique() {
		assertArrayOfArrayEquals(#[#[1], #[2], #[3]], XtendExtensions.subsetsOfSize(#[1, 2, 3], 1))
	}

	@Test
	def void testSubsetsOfSizeComplex() {
		val expected = #[#[1, 2, 3, 4], #[1, 2, 3, 5], #[1, 2, 3, 6], #[1, 2, 4, 5], #[1, 2, 4, 6], #[1, 2, 5, 6],
			#[1, 3, 4, 5], #[1, 3, 4, 6], #[1, 3, 5, 6], #[1, 4, 5, 6], #[2, 3, 4, 5], #[2, 3, 4, 6], #[2, 3, 5, 6],
			#[2, 4, 5, 6], #[3, 4, 5, 6]]

		val result = XtendExtensions.subsetsOfSize(#[1, 2, 3, 4, 5, 6], 4)

		assertArrayOfArrayEquals(expected, result)
	}

	def <T> assertArrayOfArrayEquals(List<List<T>> expected, Iterable<Iterable<T>> result) {
		XtendExtensions.biForEach(expected, result) [ expectedItem, resultItem |
			assertArrayEquals(expectedItem, resultItem)
		]
	}

}
