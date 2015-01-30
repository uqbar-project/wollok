package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.Game;
import org.uqbar.vainilla.components.behavior.Behavior;

/**
 * Makes the component stay on screen by forcing the coordinates
 * to the maximum available for the display.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class StayOnScreenBehavior extends Behavior {
  public void update(final DeltaState s) {
    double _x = this.component.getX();
    double _width = this.component.getWidth();
    double _plus = (_x + _width);
    Game _game = this.component.getGame();
    int _displayWidth = _game.getDisplayWidth();
    boolean _greaterThan = (_plus > _displayWidth);
    if (_greaterThan) {
      Game _game_1 = this.component.getGame();
      int _displayWidth_1 = _game_1.getDisplayWidth();
      double _width_1 = this.component.getWidth();
      double _minus = (_displayWidth_1 - _width_1);
      this.component.setX(_minus);
    } else {
      double _x_1 = this.component.getX();
      boolean _lessThan = (_x_1 < 0);
      if (_lessThan) {
        this.component.setX(0);
      }
    }
    double _y = this.component.getY();
    double _height = this.component.getHeight();
    double _plus_1 = (_y + _height);
    Game _game_2 = this.component.getGame();
    int _displayHeight = _game_2.getDisplayHeight();
    boolean _greaterThan_1 = (_plus_1 > _displayHeight);
    if (_greaterThan_1) {
      Game _game_3 = this.component.getGame();
      int _displayHeight_1 = _game_3.getDisplayHeight();
      double _height_1 = this.component.getHeight();
      double _minus_1 = (_displayHeight_1 - _height_1);
      this.component.setY(_minus_1);
    } else {
      double _y_1 = this.component.getY();
      boolean _lessThan_1 = (_y_1 < 0);
      if (_lessThan_1) {
        this.component.setY(0);
      }
    }
  }
}
