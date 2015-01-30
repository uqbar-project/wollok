package org.uqbar.wollok.rpg;

import org.uqbar.project.wollok.interpreter.core.WollokObject;

/**
 * Game components that reflects a WollokObject (model)
 * behind
 */
@SuppressWarnings("all")
public interface WollokObjectView {
  public abstract WollokObject getModel();
}
