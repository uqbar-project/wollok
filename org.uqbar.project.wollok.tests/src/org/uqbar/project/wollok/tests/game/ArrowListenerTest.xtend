package org.uqbar.project.wollok.tests.game

import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.listeners.ArrowListener

import static org.mockito.Mockito.*
import static org.uqbar.project.wollok.game.helpers.Keyboard.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import static org.junit.jupiter.api.Assertions.*
import org.uqbar.project.wollok.tests.game.mock.VisualComponentMock

class ArrowListenerTest {
		
	Gameboard gameboard
	Keyboard keyboard
	ArrowListener arrowListener
	VisualComponent character
	
	@BeforeEach
	def void init() {
		gameboard = Gameboard.getInstance 
		keyboard = mock(Keyboard)
		Keyboard.instance = keyboard
		
		character = new VisualComponentMock(new WGPosition(0, 0), new Image(""))
		
		arrowListener = new ArrowListener(character)
	}
	
	@Test
	def when_up_key_is_pressed_character_move_up() {
		this.press("UP")
		
		arrowListener.notify(gameboard)
		assertEquals(new WGPosition(0, 1), character.position) 
	}
	
	@Test
	def when_down_key_is_pressed_character_move_down() {
		this.press("DOWN")
		
		arrowListener.notify(gameboard)
		assertEquals(new WGPosition(0, 0), character.position) 
	}
	
	@Test
	def when_left_key_is_pressed_character_move_left() {
		this.press("LEFT")
		
		arrowListener.notify(gameboard)
		assertEquals(new WGPosition(0, 0), character.position) 
	}
	
	@Test
	def when_left_key_is_pressed_character_move_left_1() {
		character.position = new WGPosition(2, 2)		
		this.press("LEFT")

		arrowListener.notify(gameboard)
		assertEquals(new WGPosition(1, 2), character.position) 
	}
	
	@Test
	def when_right_key_is_pressed_character_move_right() {
		this.press("RIGHT")
		
		arrowListener.notify(gameboard)
		assertEquals(new WGPosition(1, 0), character.position) 
	}

	def press(String key) {
		when(keyboard.isKeyPressed(new Keyboard().getKey(key))).thenReturn(true)
	}

}