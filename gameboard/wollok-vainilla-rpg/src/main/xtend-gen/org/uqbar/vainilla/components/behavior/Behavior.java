package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.GameComponent;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public abstract class Behavior<C extends GameComponent> {
  protected C component;
  
  public abstract void update(final DeltaState s);
  
  public void attachedTo(final C c) {
    this.component = c;
  }
  
  public void removeFrom(final C c) {
    this.component = null;
  }
}
