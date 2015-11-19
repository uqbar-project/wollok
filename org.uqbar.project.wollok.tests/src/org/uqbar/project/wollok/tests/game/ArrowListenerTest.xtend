package org.uqbar.project.wollok.tests.game

import static org.mockito.Mockito.*;

import org.uqbar.project.wollok.game.listeners.ArrowListener
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.Position
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
		gameboard = mock(Gameboard)
		keyboard = mock(Keyboard)
		character = new VisualComponent(new Position(0, 0), new Image())
		
		Keyboard.instance = keyboard
		arrowListener = new ArrowListener(character)
	}
	
	@Test
	def when_up_key_is_pressed_character_move_up() {
		this.press("UP")
		
		arrowListener.notify(gameboard);
		Assert.assertEquals(new Position(0, 1), character.position) 
	}
	
	@Test
	def when_down_key_is_pressed_character_move_down() {
		this.press("DOWN")
		
		arrowListener.notify(gameboard);
		Assert.assertEquals(new Position(0, -1), character.position) 
	}
	
	@Test
	def when_left_key_is_pressed_character_move_left() {
		this.press("LEFT")
		
		arrowListener.notify(gameboard);
		Assert.assertEquals(new Position(-1, 0), character.position) 
	}
	
	@Test
	def when_right_key_is_pressed_character_move_right() {
		this.press("RIGHT")
		
		arrowListener.notify(gameboard);
		Assert.assertEquals(new Position(1, 0), character.position) 
	}
	
	def press(String key) {
		when(keyboard.isKeyPressed(new Keyboard().getKey(key))).thenReturn(true);
	}
	
}