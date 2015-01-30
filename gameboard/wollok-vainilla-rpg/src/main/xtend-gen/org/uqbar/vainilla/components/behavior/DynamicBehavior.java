package org.uqbar.vainilla.components.behavior;

import org.uqbar.vainilla.components.behavior.Behavior;

/**
 * A component to which one could attach new Behaviors
 * or remove them.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface DynamicBehavior {
  public abstract void addBehavior(final Behavior b);
  
  public abstract void removeBehavior(final Behavior b);
  
  public abstract Iterable<Behavior> getBehaviors();
}
