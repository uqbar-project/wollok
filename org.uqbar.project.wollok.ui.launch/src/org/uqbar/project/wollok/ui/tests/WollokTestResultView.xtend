package org.uqbar.project.wollok.ui.tests

import net.sf.lipermi.handler.CallHandler
import net.sf.lipermi.net.Server
import org.eclipse.jface.viewers.TreeViewer
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.ui.part.ViewPart
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.launch.io.IOUtils
import org.uqbar.project.wollok.launch.tests.WollokRemoteUITestNotifier
import org.uqbar.project.wollok.ui.launch.Activator

class WollokTestResultView extends ViewPart {

	val Server server
	val CallHandler callHandler
	val WollokUITestNotifier wollokUITestNotifier
	
	@Accessors
	val int listeningPort
	 
	new() {
		super()
		
		wollokUITestNotifier = new WollokUITestNotifier
		
		callHandler = new CallHandler
		callHandler.registerGlobal(WollokRemoteUITestNotifier, wollokUITestNotifier )
		
		server = new Server
		listeningPort = IOUtils.findFreePort
		server.bind(listeningPort,callHandler)
		
		Activator.getDefault().wollokTestResultView = this
	}
	
	var TreeViewer testTree
	
	override createPartControl(Composite parent) {
		new GridLayout() => [
			marginWidth = 0;
			marginHeight = 0;
			parent.setLayout(it);
		]
		
		testTree = new TreeViewer(parent, SWT.V_SCROLL) 
	}
	
	override protected finalize() throws Throwable {
		super.finalize()
		server.close
	}
	
	override setFocus() {
		
	}
	
	static def getView(){
		Activator.getDefault.wollokTestResultView
	}
}