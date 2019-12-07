package org.uqbar.project.wollok.tests.game;

import static org.mockito.Mockito.*;

import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.uqbar.project.wollok.game.listeners.KeyboardListener;
import org.uqbar.project.wollok.game.helpers.Keyboard
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class KeyboardListenerTest {
	
	KeyboardListener listener
	Gameboard gameboard
	Keyboard keyboard
	Runnable action
	
	@BeforeEach
	def void init() {
		val ANY_KEY = 0
		gameboard = mock(Gameboard)
		keyboard = mock(Keyboard)
		action = mock(Runnable)
		
		Keyboard.instance = keyboard		
		listener = new KeyboardListener(ANY_KEY, action)
	}
	
	@Test
	def when_no_listened_key_is_pressed_nothing_happens(){
		when(keyboard.isKeyPressed(anyInt())).thenReturn(false)
		
		listener.notify(gameboard)
		verify(action, never()).run()
	}
	
	@Test
	def when_listened_key_is_pressed_run_the_action(){
		when(keyboard.isKeyPressed(anyInt())).thenReturn(true)
		
		listener.notify(gameboard)
		verify(action).run()
	}
}