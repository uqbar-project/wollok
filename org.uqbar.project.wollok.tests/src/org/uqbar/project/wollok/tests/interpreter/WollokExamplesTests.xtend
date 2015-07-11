package org.uqbar.project.wollok.tests.interpreter

import java.io.File
import org.junit.Test
import org.junit.runners.Parameterized.Parameter
import org.junit.runners.Parameterized.Parameters
import org.uqbar.project.wollok.tests.base.AbstractWollokParameterizedInterpreterTest

/**
 * Runs all the examples in the wollok-example project that works as a unit test
 * 
 * @author tesonep
 * @author npasserini
 */
class WollokExamplesTests extends AbstractWollokParameterizedInterpreterTest {
	static val path = EXAMPLES_PROJECT_PATH + "/src/"

	@Parameter(0)
	public File program

	@Parameters(name="{0}")
	static def Iterable<Object[]> data() {
		val files = newArrayList => [
			addAll(path.listWollokPrograms)
		]
		
		files.asParameters
	}
	
	@Test
	def void runWollok() throws Exception {
		program.interpretPropagatingErrors
	}

	// ********************************************************************************************
	// ** Helpers
	// ********************************************************************************************
	
	// isFile && (name.endsWith(".wlk") || name.endsWith(".wpgm")) 
	
	static def dispatch Iterable<File> listWollokPrograms(String path) {
		new File(path).listWollokPrograms
	}
	
	static def dispatch Iterable<File> listWollokPrograms(File it){
		if(file){
			if(name.endsWith(".wlk") || name.endsWith(".wpgm"))
				#[it]
			else
				#[]
		}else{
			listFiles.map[listWollokPrograms].flatten
		}
	}
}
