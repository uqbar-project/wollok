package org.uqbar.project.wollok.tests.game

import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.WGPosition
import org.uqbar.project.wollok.game.WGVisualComponent
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.CollisionListener

import static org.mockito.Mockito.*
import static org.junit.Assert.*

/**
 * @author ? 
 */
class CollisionListenerTest {
	CollisionListener listener
	Gameboard gameboard
	VisualComponent mario
	VisualComponent aCoin
	VisualComponent otherCoin
	(VisualComponent)=>Object block
	
	@Before
	def void init() {
		gameboard = new Gameboard
		
		var image = new Image("path")
		mario = new WGVisualComponent(new WGPosition(2, 2), image)
		aCoin = new WGVisualComponent(new WGPosition(3, 3), image)
		otherCoin = new WGVisualComponent(new WGPosition(4, 4), image)
		
		gameboard.addComponents(newArrayList(mario, aCoin, otherCoin))
		
		block = mock(Function1)
		listener = new CollisionListener(mario, block)
	}
	
	@Test
	def void nothing_happens_when_components_dont_collide_with_itself(){
		listener.notify(gameboard)
		verify(block, never).apply(mario)
	}
	
	@Test
	def void when_no_components_are_colliding_with_mario_then_nothing_happens(){
		listener.notify(gameboard)
		verify(block, never).apply(aCoin)
		verify(block, never).apply(otherCoin)
	}
	
	@Test
	def void when_components_are_colliding_with_mario_then_block_is_called_with_each(){
		aCoin.position = mario.position
		otherCoin.position = mario.position
		
		listener.notify(gameboard)
		
		verify(block).apply(aCoin)
		verify(block).apply(otherCoin)
	}
	
	@Test
	def void when_components_are_colliding_but_anyone_is_mario_then_nothing_happens(){
		aCoin.position = otherCoin.position
		
		listener.notify(gameboard)
		
		verifyZeroInteractions(block)
	}
	
	@Test
	def void should_remove_listener_from_board_when_mario_is_removed(){
		gameboard.addListener(listener)
		assertTrue(containsListener)
		gameboard.remove(mario)
		assertFalse(containsListener)
	}
	
	def containsListener() {
		gameboard.listeners.contains(listener)
	}
}
