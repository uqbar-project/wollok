package flagpackage;

import org.uqbar.project.wollok.interpreter.WollokInterpreter;
import org.uqbar.project.wollok.interpreter.core.WollokObject;

import wollok.lang.AbstractJavaWrapper;
import wollok.lang.WBoolean;


public class Flag extends AbstractJavaWrapper<Boolean> {


	public Flag (WollokObject obj, WollokInterpreter interpreter) {
		super(obj, interpreter);
		this.setWrapped(false);
	}

	
	public void value(WollokObject value) {
		this.setWrapped(value.getNativeObject(WBoolean.class).getWrapped());
	}

	public Boolean value() {
		return this.getWrapped();
	}
	

}