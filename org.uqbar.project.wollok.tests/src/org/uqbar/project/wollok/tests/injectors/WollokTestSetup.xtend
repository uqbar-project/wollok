package org.uqbar.project.wollok.tests.injectors

import com.google.inject.Guice
import org.apache.log4j.Logger
import org.apache.log4j.PropertyConfigurator
import org.uqbar.project.wollok.launch.WollokLauncherParameters
import org.uqbar.project.wollok.launch.setup.WollokLauncherModule
import org.uqbar.project.wollok.launch.setup.WollokLauncherSetup

class WollokTestSetup extends WollokLauncherSetup {
	new(WollokLauncherParameters params) {
		super(params)
	}

	override createInjector() {
		return Guice.createInjector(new WollokTestModule(params), this);
	}
}

class WollokTestModule extends WollokLauncherModule{

	public static val ROOT_LOGGER = {
		WollokTestModule.configureLog4j
	}

	protected static def Logger configureLog4j() {
	
		val envVariable = System.getenv("CI")

		if(envVariable === null)
			configureLog4j("/log4j-normal.properties")
		else
			configureLog4j("/log4j-travis.properties")		
		
		Logger.rootLogger
	}

	protected static def void configureLog4j(String filename){
		val url = WollokTestInjectorProvider.getResource(filename)
		
		if(url === null){
			throw new RuntimeException("Could not find file in classpath:" + filename)
		}

		val conf = new PropertyConfigurator()
		Logger.rootLogger.loggerRepository.resetConfiguration
		conf.doConfigure(url, Logger.rootLogger.loggerRepository)
	}

	new(WollokLauncherParameters params) {
		super(params)
	}
}