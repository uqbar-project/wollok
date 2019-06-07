package org.uqbar.project.wollok.tests.multithread

import java.util.concurrent.CountDownLatch
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import org.apache.log4j.Logger
import org.junit.Ignore
import org.junit.Test
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterException
import org.uqbar.project.wollok.interpreter.core.WollokProgramExceptionWrapper
import org.uqbar.project.wollok.interpreter.debugger.XDebuggerOff
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.tests.injectors.WollokTestSetup
import org.uqbar.project.wollok.tests.interpreter.WollokParseHelper

import static org.junit.Assert.*

/**
 * 
 * @author npasserini
 */
class WollokMultiInterpreterTest {
	val Logger log = Logger.getLogger(this.class)

	@Test
	def void testRunSameProgramTwice() {
		val parameters = new WollokLauncherParameters()
		val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val interpreter = injector.getInstance(WollokInterpreter)
		val debugger = new XDebuggerOff
		interpreter.addInterpreterListener(debugger)

		var program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 10 }
			} 
			
			test "pepita vuela" {
				pepita.volar()
				assert.equals(90, pepita.energia())
			}			
		'''
		interpreter.interpret(program.parse)

		try {
			program = '''
			test "pepita vuela" {
				pepita.volar()
				assert.equals(90, pepita.energia())
			}					
			'''
			interpreter.interpret(program.parse, true)
			fail()
		} catch (WollokInterpreterException ex) {
			// Ok
		}
	}

	@Test
	@Ignore
	def void testRunALotOfPrograms() {
		val numberOfThreads = 4
		val numberOfTimes = 5
		var startTime = System.currentTimeMillis

		val parameters = new WollokLauncherParameters()
		val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 1 }
			} 
			
			test "pepita vuela" {
				(1..100).forEach{ i => 
					pepita.volar()
					//console.println(pepita.energia())
					assert.equals(100-i, pepita.energia())
				}
			}
		'''

		(1..numberOfTimes).forEach[
			val start = new CountDownLatch(1)
			val stop = new CountDownLatch(numberOfThreads)
	
			val Runnable block = [
				start.await
				val interpreter = injector.getInstance(WollokInterpreter)
				interpreter.addInterpreterListener(new XDebuggerOff)
				try{
					interpreter.interpret(program.parse, true)
				}catch(WollokProgramExceptionWrapper e){
					log.error(e.wollokMessage)
					log.error(e.wollokStackTrace)
				}
				stop.countDown
			]

			val threads = (1..numberOfThreads).map[new Thread(block)]
			threads.forEach[it.start]
			start.countDown
			if(!stop.await(2, TimeUnit.MINUTES)){
				threads.forEach[if(alive)interrupt]
				fail("This have taken longer as expected")
			}	
		]
		
		var time = System.currentTimeMillis - startTime
		
		log.debug("Tiempo(" + numberOfThreads + "):" + time)
	}

	@Test
	def void testWithRunner(){
		val numberOfPrograms = 50 
		val numberOfThreads = 4
		var startTime = System.currentTimeMillis

		val parameters = new WollokLauncherParameters()
		val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration
		val extension parserHelper = injector.getInstance(WollokParseHelper)

		val program = '''
			object pepita {
				var energia = 100
				method energia() = energia
				method volar() { energia -= 1 }
			} 
			
			test "pepita vuela" {
				(1..100).forEach{ i => 
					pepita.volar()
					console.println(pepita.energia())
					assert.equals(100-i, pepita.energia())
				}
			}
		'''

		val Runnable block = [
			val interpreter = injector.getInstance(WollokInterpreter)
			interpreter.addInterpreterListener(new XDebuggerOff)
			interpreter.interpret(program.parse, true)
		]

		
		val worker = new ScheduledThreadPoolExecutor(numberOfThreads)
		(1..numberOfPrograms).forEach[
			worker.submit(block)
		]
		
		worker.shutdown()
		worker.awaitTermination(2, TimeUnit.MINUTES)
		
		var time = System.currentTimeMillis - startTime
		
		log.debug("Tiempo(" + numberOfThreads + "):" + time)
	}

	@Test
	def void testGetInjectorTwice() {
		val parameters = new WollokLauncherParameters()
		val injector = new WollokTestSetup(parameters).createInjectorAndDoEMFRegistration
		
		assertNotSame(injector.getInstance(WollokInterpreter), injector.getInstance(WollokInterpreter))
	}
}
