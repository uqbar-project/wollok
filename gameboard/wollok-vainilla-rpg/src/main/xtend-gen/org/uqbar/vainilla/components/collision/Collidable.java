package org.uqbar.vainilla.components.collision;

import com.uqbar.vainilla.colissions.Circle;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public interface Collidable {
  public abstract void collidesWith(final Collidable other);
  
  public abstract Circle getCirc();
}
