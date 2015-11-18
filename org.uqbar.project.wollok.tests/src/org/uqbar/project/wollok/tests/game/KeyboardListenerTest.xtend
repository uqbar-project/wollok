package org.uqbar.project.wollok.tests.game;

import static org.mockito.Mockito.*;

import org.junit.Before;
import org.junit.Test;

import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.uqbar.project.wollok.game.listeners.KeyboardListener;

class KeyboardListenerTest {
	
	KeyboardListener leftListener;
	Gameboard gameboard;
	Runnable action;
	
	@Before
	def void init() {
		val LEFT = 0
		gameboard = mock(Gameboard)
		action = mock(Runnable)
		leftListener = new KeyboardListener(LEFT, action)
	}
	
	@Test
	def when_no_listened_key_is_pressed_nothing_happens(){
		leftListener.notify(gameboard);
		verify(action, never()).run();
	}
	
	@Test
	def when_listened_key_is_pressed_run_the_action(){
		when(gameboard.isKeyPressed(anyInt())).thenReturn(true);
		leftListener.notify(gameboard);
		verify(action).run();
	}
}