package org.uqbar.project.wollok.tests.debugger

import org.junit.Test

/**
 * Tests a breakpoint being hit by the debugger/interpreter
 * 
 * @author jfernandes
 */
class BreakPointHitTestCase extends AbstractXDebuggingTestCase {
	
	@Test
	def void hittingABreakPointShouldRiseAndEvent() {
		'''
			program abc {
				console.println("hello")
				var a = 123
				console.println("a is" + a)
			}
		'''.debugSession [
			setBreakPoint(4)
		   	expect [ 
				on(suspended).thenDo[ resume ]
				on(breakPointHit(4))
					.checkThat [vm |
						val frames = vm.stackFrames
						// 1 stack level
						assertNotNull(frames)
						assertEquals(1, frames.size)
						
						// 1 variable (a = 123)
						assertEquals(1, frames.get(0).variables.size)
						frames.get(0).variables.get(0) => [
							assertEquals("a", variable.name)
							assertEquals("123", value.stringValue)	
						]
					]
					.thenDo [ resume ]
			]
		]		
	}
	
//	@Test
	def void listShouldHaveElements() {
		'''
			program abc {
				var aList = [1,2,3]
				console.println(aList)
			}
		'''.debugSession [
			setBreakPoint(3)
		   	expect [ 
				on(suspended).thenDo[ resume ]
				on(breakPointHit(3))
					.checkThat [vm |
						val frames = vm.stackFrames
						// 1 stack level
						assertNotNull(frames)
						assertEquals(1, frames.size)
						
						// 1 variable (aList)
						assertEquals(1, frames.get(0).variables.size)
						frames.get(0).variables.get(0) => [
							assertEquals("aList", variable.name)
							assertTrue(value.stringValue.startsWith("List (id="))	
							
							// list should have elements
							assertEquals(3, value.variables.length)
						]
					]
					.thenDo [ resume ]
			]
		]		
	}
	
}