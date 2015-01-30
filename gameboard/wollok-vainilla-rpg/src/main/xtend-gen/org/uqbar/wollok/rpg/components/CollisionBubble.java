package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.GameComponent;
import java.awt.Color;
import org.uqbar.vainilla.appearances.RoundedRectangle;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class CollisionBubble extends GameComponent {
  public CollisionBubble(final int x, final int y, final int width, final int height) {
    super(x, y);
    Color _color = new Color(0, 0, 225, 180);
    RoundedRectangle _roundedRectangle = new RoundedRectangle(_color, width, height, 10);
    this.setAppearance(_roundedRectangle);
  }
}
