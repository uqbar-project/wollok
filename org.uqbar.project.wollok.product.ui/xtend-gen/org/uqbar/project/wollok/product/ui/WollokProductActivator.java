package org.uqbar.project.wollok.product.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * Activator for the wollok product.
 * It has the programmatic code to hack eclipse workbench
 * removing cluttering like wizards we don't want and preferences pages, menues, etc.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class WollokProductActivator extends AbstractUIPlugin {
  public final static String PLUGIN_ID = "org.uqbar.project.wollok.product.ui";
  
  private static WollokProductActivator plugin;
  
  @Override
  public void start(final BundleContext context) throws Exception {
    super.start(context);
    WollokProductActivator.plugin = this;
  }
  
  @Override
  public void stop(final BundleContext context) throws Exception {
    WollokProductActivator.plugin = null;
    super.stop(context);
  }
}
