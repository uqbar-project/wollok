package org.uqbar.project.wollok.tests.game

import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Messages
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.WGVisualComponent
import org.uqbar.project.wollok.game.gameboard.Background
import org.uqbar.project.wollok.game.gameboard.CellsBackground
import org.uqbar.project.wollok.game.gameboard.FullBackground
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.game.helpers.Application
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper

import static org.junit.Assert.*
import static org.mockito.Mockito.*
import static org.uqbar.project.wollok.game.helpers.Application.*
import static org.uqbar.project.wollok.game.helpers.Keyboard.*

class GameboardTest {
	Gameboard gameboard
	GameboardListener listener
	VisualComponent component
	VisualComponent character
	Window window

	@Before
	def void init() {
		Keyboard.instance = mock(Keyboard)
		Application.instance = mock(Application)
		listener = mock(GameboardListener)
		component = newComponent(position(0, 0))
		character = newComponent(position(1, 0))
		window = mock(Window)
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
		var otherComponent = newComponent(position(1, 0))
		gameboard.addComponent(otherComponent)
		assertArrayEquals(#[character, otherComponent], gameboard.getComponentsInPosition(position(1, 0)))
	}

	@Test
	def on_rendering_notify_the_listeners() {
		gameboard.draw(window)

		verify(listener).notify(gameboard)
	}

	@Test
	def on_rendering_draw_background_components_and_character_in_order() {
		val background = mock(Background)
		gameboard.background = background

		gameboard.draw(window)

		var inOrder = inOrder(background, component, character)
		inOrder.verify(background).draw(window)
		inOrder.verify(component).draw(window)
		inOrder.verify(character).draw(window)
	}
	
	@Test
	def report_error_with_character() {
		listenerThrowError
		
		gameboard.draw(window)

		verifyErrorReporter(character)
	}

	@Test
	def report_error_with_error_reporter() {
		listenerThrowError
		
		gameboard => [
			errorReporter(component)
			draw(window)
		]

		verifyErrorReporter(component)
	}

	@Test
	def report_error_with_source() {
		component.WObject = mock(WollokObject)
		listenerThrowErrorFrom(component.WObject)
		
		gameboard.draw(window)
		
		verifyErrorReporter(component)
	}
	
	@Test
	def report_error_without_reporter() {
		listenerThrowError
		
		gameboard.character = null
		gameboard.draw(window)

		verifyErrorReporter(character)
	}
	
	@Test
	def report_error_without_components_nothing_happends() {
		listenerThrowError
		
		gameboard.clear
		gameboard.addListener(listener)
		gameboard.draw(window)
	}
	
	@Test
	def report_error_without_message() {
		listenerThrowErrorWithMessage(newWollokException(null, null))
		
		gameboard.draw(window)

		verify(character).scream(Messages.WollokGame_NoMessage)
	}
	
	def verifyErrorReporter(VisualComponent component) {
		verify(component).scream("ERROR")
	}

	def position(int x, int y) {
		new WGPosition(x, y)
	}

	def newComponent() {
		newComponent(position(0, 0))
	}

	def newComponent(Position p) {
		spy(new WGVisualComponent(p, new Image("")) => [ hideAttributes ])
	}
	
	def listenerThrowError() { listenerThrowErrorWithMessage(newWollokException("ERROR", null)) }
	
	def listenerThrowErrorFrom(WollokObject source) { listenerThrowErrorWithMessage(newWollokException("ERROR", source)) }
	
	def listenerThrowErrorWithMessage(WollokProgramExceptionWrapper exception) {
		doThrow(exception).when(listener).notify(gameboard)
	}
	
	def newWollokException(String message, WollokObject source) {
		val exception = mock(WollokProgramExceptionWrapper)
		when(exception.wollokMessage).thenReturn(message)
		when(exception.wollokSource).thenReturn(source)
		exception
	}
}
