package org.uqbar.project.wollok.tests.game

import org.eclipse.xtext.xbase.lib.Functions.Function0
import org.junit.Before
import org.junit.Test
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.listeners.ScheduleListener
import org.uqbar.project.wollok.game.listeners.TimeListener

import static org.junit.Assert.*
import static org.mockito.Mockito.*

class TimeListenerTest {
	TimeListener interval
	ScheduleListener schedule
	Gameboard gameboard
	()=>Object block
	
	@Before
	def void init() {
		gameboard = new Gameboard
		block = mock(Function0)
		interval = new TimeListener("", -1, block)
		schedule = new ScheduleListener(-1, block)
	}
	
	@Test
	def void interval_executes_every_time(){
		gameboard.addListener(interval)
		gameboard.update()
		gameboard.update()
		verify(block, times(2)).apply()
	}
	
	@Test
	def void schedule_executes_one_time(){
		gameboard.addListener(schedule)
		gameboard.update()
		gameboard.update()
		verify(block, only).apply()
	}
	
	@Test
	def void after_schedule_executes_it_is_removed(){
		gameboard.addListener(schedule)
		gameboard.update()
		assertFalse(containsListener(schedule))
	}

	
	def containsListener(GameboardListener listener) {
		gameboard.listeners.contains(listener)
	}
}
