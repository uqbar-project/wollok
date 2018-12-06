package org.uqbar.project.wollok.tests.game

import static org.mockito.Mockito.*;

import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WGVisualComponent
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.Image

import org.junit.Before
import org.junit.Test
import org.junit.Assert

class ArrowListenerTest {
		
	Gameboard gameboard
	Keyboard keyboard
	ArrowListener arrowListener
	VisualComponent character
	
	@Before
	def void init() {
		gameboard = Gameboard.getInstance 
		keyboard = mock(Keyboard)
		Keyboard.instance = keyboard
		
		character = new WGVisualComponent(new WGPosition(0, 0), new Image())
		
		arrowListener = new ArrowListener(character)
	}
	
	@Test
	def when_up_key_is_pressed_character_move_up() {
		this.press("UP")
		
		arrowListener.notify(gameboard)
		Assert.assertEquals(new WGPosition(0, 1), character.position) 
	}
	
	@Test
	def when_down_key_is_pressed_character_move_down() {
		this.press("DOWN")
		
		arrowListener.notify(gameboard)
		Assert.assertEquals(new WGPosition(0, 0), character.position) 
	}
	
	@Test
	def when_left_key_is_pressed_character_move_left() {
		this.press("LEFT")
		
		arrowListener.notify(gameboard)
		Assert.assertEquals(new WGPosition(0, 0), character.position) 
	}
	
	@Test
	def when_left_key_is_pressed_character_move_left_1() {
		character.position = new WGPosition(2, 2)		
		this.press("LEFT")

		arrowListener.notify(gameboard)
		Assert.assertEquals(new WGPosition(1, 2), character.position) 
	}
	
	@Test
	def when_right_key_is_pressed_character_move_right() {
		this.press("RIGHT")
		
		arrowListener.notify(gameboard)
		Assert.assertEquals(new WGPosition(1, 0), character.position) 
	}

//	@Test
//	def when_right_key_is_pressed_character_move_right_2() {
//		character.position = new WGPosition(4, 4)
//		this.press("RIGHT")
//		
//		arrowListener.notify(gameboard)
//		Assert.assertEquals(new WGPosition(4, 4), character.position) 
//	}
	
	def press(String key) {
		when(keyboard.isKeyPressed(new Keyboard().getKey(key))).thenReturn(true)
	}

}