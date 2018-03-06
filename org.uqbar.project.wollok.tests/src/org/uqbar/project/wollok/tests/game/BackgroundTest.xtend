package org.uqbar.project.wollok.tests.game

import org.junit.Test
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.gameboard.CellsBackground
import org.uqbar.project.wollok.game.gameboard.FullBackground
import org.uqbar.project.wollok.game.gameboard.Window

import static org.mockito.Matchers.*
import static org.mockito.Mockito.*

class BackgroundTest {
	val image = "image.png"
	val window = mock(Window)
	
	@Test
	def cells_background_should_draw_image_in_all_positions() {
		new CellsBackground(image, 3, 5).draw(window)
		verify(window, times(3 * 5)).draw(any, any)
	}
	
	@Test
	def full_background_should_draw_full_image_at_origin() {
		new FullBackground(image).draw(window)
		verify(window).fullDraw(any, eq(new WGPosition(0,0)))
	}	
}