package org.uqbar.project.wollok.launch

import com.google.inject.Injector
import java.io.File
import org.eclipse.xtext.resource.SaveOptions
import org.eclipse.xtext.serializer.ISerializer
import org.uqbar.project.wollok.wollokDsl.WFile

class WollokFormatter extends WollokChecker {
	
	def static void main(String[] args) {
		new WollokFormatter().doMain(args)
	}
	
	override doSomething(WFile parsed, Injector injector, File mainFile, WollokLauncherParameters parameters) {
		val serializer = injector.getInstance(ISerializer)
		val options = SaveOptions.newBuilder.format().getOptions()
		println(serializer.serialize(parsed, options))
	}
	
}