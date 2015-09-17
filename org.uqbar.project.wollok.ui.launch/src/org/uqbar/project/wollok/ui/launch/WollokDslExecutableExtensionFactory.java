package org.uqbar.project.wollok.ui.launch;

import org.eclipse.xtext.ui.guice.AbstractGuiceAwareExecutableExtensionFactory;
import org.osgi.framework.Bundle;

import com.google.inject.Injector;

/**
 * I should copy this class because It can only be used in the same plugin. 
 */
public class WollokDslExecutableExtensionFactory extends AbstractGuiceAwareExecutableExtensionFactory {

	@Override1
	protected Bundle getBundle() {
		return Activator.getDefault().getBundle();
	}
	
	@Override
	protected Injector getInjector() {
		return Activator.getDefault().getInjector();
	}
	
}
