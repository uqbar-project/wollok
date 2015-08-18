package org.uqbar.project.wollok.tests.game;

import static org.mockito.Mockito.*;

import java.util.Arrays;
import java.util.function.Consumer;

import org.junit.Before;
import org.junit.Test;
import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.Position;
import org.uqbar.project.wollok.game.VisualComponent;
import org.uqbar.project.wollok.game.gameboard.Gameboard;
import org.uqbar.project.wollok.game.listeners.CollisionListener;

public class CollisionListenerTest {

	private CollisionListener collisionListener;
	private Gameboard gameboard;
	private VisualComponent mario;
	private VisualComponent aCoin;
	private VisualComponent otherCoin;
	private Consumer<VisualComponent> block;
	
	@SuppressWarnings("unchecked")
	@Before
	public void init() {
		mario = new VisualComponent();
		mario.setMyPosition(new Position(2, 2));
		
		aCoin = new VisualComponent();
		aCoin.setMyPosition(new Position(3, 3));
		
		otherCoin = new VisualComponent();
		otherCoin.setMyPosition(new Position(4, 4));
		
		gameboard = new Gameboard();
		GameConfiguration config = new GameConfiguration();
		config.setGameboardWidth(5);
		config.setGameboardHeight(5);
		gameboard.setConfiguration(config);
		gameboard.setComponents(Arrays.asList(mario, aCoin, otherCoin));
		
		block = mock(Consumer.class);
		collisionListener = new CollisionListener(mario, block);
	}
	
	@Test
	public void components_dont_collide_with_itself(){
		collisionListener.notify(gameboard);
		verify(block, never()).accept(mario);
	}
	
	@Test
	public void when_no_components_are_colliding_with_mario_then_nothing_happens(){
		collisionListener.notify(gameboard);
		verify(block, never()).accept(aCoin);
		verify(block, never()).accept(otherCoin);
	}
	
	@Test
	public void when_components_are_colliding_with_mario_then_block_is_called_with_each(){
		aCoin.setMyPosition(mario.getMyPosition());
		otherCoin.setMyPosition(mario.getMyPosition());
		
		collisionListener.notify(gameboard);
		verify(block).accept(aCoin);
		verify(block).accept(otherCoin);
	}
	
	@Test
	public void when_components_are_colliding_but_anyone_is_mario_then_nothing_happens(){
		aCoin.setMyPosition(otherCoin.getMyPosition());
		
		collisionListener.notify(gameboard);
		verify(block, never()).accept(aCoin);
		verify(block, never()).accept(otherCoin);
	}
}
