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
		verifyZeroInteractions(block)
	}
	
	@Test
	def void block_is_called_on_each_notify(){
		aCoin.position = mario.position
		
		listener.notify(gameboard)
		listener.notify(gameboard)
		
		verify(block, times(2)).apply(aCoin)
	}
	
	@Test
	def void block_is_called_with_each_colliding_component(){
		aCoin.position = mario.position
		otherCoin.position = mario.position
		
		listener.notify(gameboard)
		
		verify(block).apply(aCoin)
		verify(block).apply(otherCoin)
	}
	
	@Test
	def void nothing_happens_when_non_observed_components_are_colliding(){
		aCoin.position = otherCoin.position
		
		listener.notify(gameboard)
		
		verifyZeroInteractions(block)
	}
	
	@Test
	def void should_keep_board_listener_when_observed_component_is_removed(){
		gameboard.addListener(listener)
		gameboard.remove(mario)
		assertTrue(containsListener)
	}
	
	def containsListener() {
		gameboard.listeners.contains(listener)
	}
}
