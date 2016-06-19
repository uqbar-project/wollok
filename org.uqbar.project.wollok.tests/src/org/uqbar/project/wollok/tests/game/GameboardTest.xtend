package org.uqbar.project.wollok.tests.game

import static org.mockito.Mockito.*

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.gameboard.Window
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Cell
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.Image

/**
 * @author ?
 */
class GameboardTest {
	Gameboard gameboard
	GameboardListener listener
	VisualComponent component
	VisualComponent character
	Cell cell

	@Before
	def void init(){
		Keyboard.setInstance(mock(Keyboard))
		gameboard = new Gameboard => [
			title = "UnTitulo"
			width = 2
			height = 5
		]
		
		listener = mock(GameboardListener)
		gameboard.addListener(listener)
		component = createComponent(new WGPosition(0, 0))
		
		gameboard.addComponent(component)
		character = createComponent(new WGPosition(1, 0))
		gameboard.addCharacter(character)
	}
	
	@Test
	def should_init_with_defaults() {
		gameboard = new Gameboard
		Assert.assertEquals("Wollok Game", gameboard.title)
		Assert.assertEquals(5, gameboard.width)
		Assert.assertEquals(5, gameboard.height)
		Assert.assertEquals("ground.png", gameboard.cells.head.image.path)
	}
	
	@Test
	def should_create_all_cells() {
		gameboard.createCells("UnaImagen")
		Assert.assertEquals(10, gameboard.cells.size)
	}
	
	@Test
	def can_return_all_components_in_a_position() {
		var otherComponent = createComponent(new WGPosition(1, 0))
		gameboard.addComponent(otherComponent)
		Assert.assertArrayEquals(#[character, otherComponent], gameboard.getComponentsInPosition(new WGPosition(1, 0)))
	}
	
	@Test
	def on_rendering_notify_the_listeners() {
		var window = mock(Window)
		gameboard.draw(window)
		
		verify(this.listener).notify(gameboard)
	}
	
	@Test
	def on_rendering_draw_cells_components_and_character_in_order() {
		cell = mock(Cell)
		gameboard.cells.add(cell)
		
		var window = mock(Window)
		gameboard.draw(window)
		
 		var inOrder = inOrder(cell, component, character)
		inOrder.verify(cell).draw(window)
		inOrder.verify(component).draw(window)
		inOrder.verify(character).draw(window)
	}

	
	def createComponent(Position p) {
		mock(VisualComponent) => [
			when(position).thenReturn(p)	
		]
	}
}