package org.uqbar.project.wollok.tests.game

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.gameboard.Background
import org.uqbar.project.wollok.game.gameboard.CellsBackground
import org.uqbar.project.wollok.game.gameboard.FullBackground
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.game.helpers.Application
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.listeners.GameboardListener

import static org.junit.Assert.*
import static org.mockito.Mockito.*
import static org.uqbar.project.wollok.game.helpers.Application.*
import static org.uqbar.project.wollok.game.helpers.Keyboard.*

class GameboardTest {
	Gameboard gameboard
	GameboardListener listener
	VisualComponent component
	VisualComponent character

	@Before
	def void init() {
		Keyboard.instance = mock(Keyboard)
		Application.instance = mock(Application)
		listener = mock(GameboardListener)
		component = createComponent(position(0, 0))
		character = createComponent(position(1, 0))

		gameboard = new Gameboard => [
			title = "UnTitulo"
			width = 3
			height = 5
			background = mock(Background)
			addListener(listener)
			addComponent(component)
			addCharacter(character)
		]
	}

	@Test
	def should_init_with_defaults() {
		gameboard = new Gameboard
		assertEquals("Wollok Game", gameboard.title)
		assertEquals(5, gameboard.width)
		assertEquals(5, gameboard.height)
		assertEquals("ground.png", gameboard.ground)
	}

	@Test
	def on_start_should_create_cells_background() {
		gameboard.start
		assertEquals(CellsBackground, gameboard.background.class)
	}
	
	@Test
	def when_boardGround_is_not_null_should_create_full_background() {
		gameboard => [
			boardGround = "background.png"
			start
		]
		assertEquals(FullBackground, gameboard.background.class)
	}

	@Test
	def can_return_all_components_in_a_position() {
		var otherComponent = createComponent(position(1, 0))
		gameboard.addComponent(otherComponent)
		assertArrayEquals(#[character, otherComponent], gameboard.getComponentsInPosition(position(1, 0)))
	}

	@Test
	def on_rendering_notify_the_listeners() {
		var window = mock(Window)
		gameboard.draw(window)

		verify(listener).notify(gameboard)
	}

	@Test
	def on_rendering_draw_background_components_and_character_in_order() {
		val background = mock(Background)
		gameboard.background = background

		var window = mock(Window)
		gameboard.draw(window)

		var inOrder = inOrder(background, component, character)
		inOrder.verify(background).draw(window)
		inOrder.verify(component).draw(window)
		inOrder.verify(character).draw(window)
	}
	
	def position(int x, int y) {
		new WGPosition(x, y)
	}

	def createComponent(Position p) {
		mock(VisualComponent) => [
			when(position).thenReturn(p)
		]
	}
}
