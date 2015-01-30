package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.appearances.Animation;
import com.uqbar.vainilla.appearances.Sprite;
import com.uqbar.vainilla.colissions.Rectangle;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.Point2D;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.uqbar.vainilla.components.collision.Collidable;
import org.uqbar.wollok.rpg.WollokMovingGameComponent;
import org.uqbar.wollok.rpg.scenes.WollokRPGScene;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class VainillaExtensions {
  public static Animation asAnimation(final Sprite sprite, final double meanTime, final int amountOfFrames) {
    double _height = sprite.getHeight();
    return VainillaExtensions.parseAnimation(sprite, 0, (((int) sprite.getWidth()) / amountOfFrames), ((int) _height), meanTime);
  }
  
  public static Animation parseAnimation(final Sprite tiles, final int y, final int tileWidth, final int tileHeight, final double meanTime) {
    Animation _xblockexpression = null;
    {
      final ArrayList<Sprite> frames = CollectionLiterals.<Sprite>newArrayList();
      int x = 0;
      double _width = tiles.getWidth();
      boolean _lessThan = (x < _width);
      boolean _while = _lessThan;
      while (_while) {
        {
          Sprite _crop = tiles.crop(x, y, tileWidth, tileHeight);
          frames.add(_crop);
          int _x = x;
          x = (_x + tileWidth);
        }
        double _width_1 = tiles.getWidth();
        boolean _lessThan_1 = (x < _width_1);
        _while = _lessThan_1;
      }
      _xblockexpression = new Animation(meanTime, ((Sprite[])Conversions.unwrapArray(frames, Sprite.class)));
    }
    return _xblockexpression;
  }
  
  public static double rightOf(final GameComponent c) {
    double _x = c.getX();
    double _width = c.getWidth();
    return (_x + _width);
  }
  
  public static List<Collidable> collidingComponents(final WollokMovingGameComponent c) {
    WollokRPGScene _scene = c.getScene();
    return _scene.collisions(((Collidable) c));
  }
  
  public static void antialiasingOn(final Graphics2D g) {
    g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
    g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
  }
  
  public static boolean contains(final Rectangle rect, final Point2D.Double p) {
    boolean _and = false;
    boolean _and_1 = false;
    boolean _and_2 = false;
    double _x = rect.getX();
    boolean _greaterEqualsThan = (p.x >= _x);
    if (!_greaterEqualsThan) {
      _and_2 = false;
    } else {
      double _x_1 = rect.getX();
      double _width = rect.getWidth();
      double _plus = (_x_1 + _width);
      boolean _lessEqualsThan = (p.x <= _plus);
      _and_2 = _lessEqualsThan;
    }
    if (!_and_2) {
      _and_1 = false;
    } else {
      double _y = rect.getY();
      boolean _greaterEqualsThan_1 = (p.y >= _y);
      _and_1 = _greaterEqualsThan_1;
    }
    if (!_and_1) {
      _and = false;
    } else {
      double _y_1 = rect.getY();
      double _height = rect.getHeight();
      double _plus_1 = (_y_1 + _height);
      boolean _lessEqualsThan_1 = (p.y <= _plus_1);
      _and = _lessEqualsThan_1;
    }
    return _and;
  }
}
