package wollok.lib;

import org.uqbar.project.wollok.interpreter.WollokInterpreter;

public class ConsoleObject {
	public void println(Object obj){
		WollokInterpreter.getInstance().getConsole().logMessage("" + obj);
	}
}
