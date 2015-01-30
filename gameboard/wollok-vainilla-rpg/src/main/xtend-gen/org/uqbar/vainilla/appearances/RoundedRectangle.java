package org.uqbar.vainilla.appearances;

import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.appearances.Rectangle;
import java.awt.Color;
import java.awt.Graphics2D;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class RoundedRectangle extends Rectangle {
  private int arcWidth;
  
  private int arcHeight;
  
  public RoundedRectangle(final Color color, final int width, final int height, final int arcWidthAndHeight) {
    this(color, width, height, arcWidthAndHeight, arcWidthAndHeight);
  }
  
  public RoundedRectangle(final Color color, final int width, final int height, final int arcWidth, final int arcHeight) {
    super(color, width, height);
    this.arcWidth = arcWidth;
    this.arcHeight = arcHeight;
  }
  
  public void render(final GameComponent<?> component, final Graphics2D graphics) {
    Color _color = this.getColor();
    graphics.setColor(_color);
    double _x = component.getX();
    double _y = component.getY();
    double _width = this.getWidth();
    double _height = this.getHeight();
    graphics.fillRoundRect(((int) _x), ((int) _y), ((int) _width), ((int) _height), this.arcWidth, this.arcHeight);
  }
}
