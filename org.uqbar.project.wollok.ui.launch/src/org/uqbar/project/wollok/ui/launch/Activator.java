package org.uqbar.project.wollok.ui.launch;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;
import org.uqbar.project.wollok.launch.WollokLauncherException;
import org.uqbar.project.wollok.ui.WollokActivator;
import org.uqbar.project.wollok.ui.tests.WollokTestsResultsListener;

import com.google.inject.Injector;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {
	public static final String LAUNCHER_PLUGIN_ID = "org.uqbar.project.wollok.launch";
	public static final String PLUGIN_ID = "org.uqbar.project.wollok.ui.launch";
	private static Activator plugin;

	private WollokTestsResultsListener wollokTestsResultListener;

	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
		wollokTestsResultListener = getInjector().getInstance(WollokTestsResultsListener.class);
	}

	public void stop(BundleContext context) throws Exception {
		plugin = null;
		super.stop(context);
		wollokTestsResultListener.close();
	}


	public ImageDescriptor getImageDescriptor(String name) {
		try {
			// First of all, we try to find image from shared images of Workbench (defined in target platform project)
			// http://www.eclipse.org/articles/Article-Using%20Images%20In%20Eclipse/Using%20Images%20In%20Eclipse.html
			// http://help.eclipse.org/mars/index.jsp?topic=%2Forg.eclipse.pde.doc.user%2Fguide%2Ftools%2Fviews%2Fimage_browser_view.htm 
			ImageDescriptor id = PlatformUI.getWorkbench().getSharedImages().getImageDescriptor(name);
			if (id != null) {
				return id;
			}
			URL u = new URL(this.getDefault().getStateLocation().toFile().toURL(), name);
			return ImageDescriptor.createFromURL(u);
		} catch (MalformedURLException e) {
			throw new WollokLauncherException("Error while loading image ["
					+ name + "]", e);
		}
	}
	
//	public ImageDescriptor getImageDescriptor(String name) {
//		URL u = find(this.getDefault().getStateLocation().append(name));
//		System.out.println(u);
//		return ImageDescriptor.createFromURL(u);
//	}

	public static Activator getDefault() {
		return plugin;
	}

	public WollokTestsResultsListener getWollokTestsResultListener() {
		return wollokTestsResultListener;
	}

	public Integer getWollokTestViewListeningPort() {
		return this.getWollokTestsResultListener().getListeningPort();
	}

	public Injector getInjector(){
		return WollokActivator.getInstance().getInjector(WollokActivator.ORG_UQBAR_PROJECT_WOLLOK_WOLLOKDSL);
	}
	
}
