package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.MovingGameComponent;
import com.uqbar.vainilla.UnitVector2D;
import com.uqbar.vainilla.events.constants.Key;
import org.uqbar.vainilla.components.behavior.Behavior;

/**
 * Moves the component along x and y axis based on keyboard hits.
 * right, left, up and down.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class MovesWithKeyboard extends Behavior<MovingGameComponent> {
  private Key _upKey = Key.UP;
  
  public Key getUpKey() {
    return this._upKey;
  }
  
  public void setUpKey(final Key upKey) {
    this._upKey = upKey;
  }
  
  private Key _downKey = Key.DOWN;
  
  public Key getDownKey() {
    return this._downKey;
  }
  
  public void setDownKey(final Key downKey) {
    this._downKey = downKey;
  }
  
  private Key _leftKey = Key.LEFT;
  
  public Key getLeftKey() {
    return this._leftKey;
  }
  
  public void setLeftKey(final Key leftKey) {
    this._leftKey = leftKey;
  }
  
  private Key _rightKey = Key.RIGHT;
  
  public Key getRightKey() {
    return this._rightKey;
  }
  
  public void setRightKey(final Key rightKey) {
    this._rightKey = rightKey;
  }
  
  public int getMaxSpeed() {
    return 250;
  }
  
  public void update(final DeltaState s) {
    final int xV = this.xVector(s);
    final int yV = this.yVector(s);
    if (((xV == 0) && (yV == 0))) {
      this.component.setSpeed(0);
    } else {
      UnitVector2D _uVector = this.component.getUVector();
      _uVector.set(xV, yV);
      int _maxSpeed = this.getMaxSpeed();
      this.component.setSpeed(_maxSpeed);
    }
  }
  
  public int yVector(final DeltaState s) {
    int _xifexpression = (int) 0;
    Key _upKey = this.getUpKey();
    boolean _isKeyBeingHold = s.isKeyBeingHold(_upKey);
    if (_isKeyBeingHold) {
      _xifexpression = (-1);
    } else {
      int _xifexpression_1 = (int) 0;
      Key _downKey = this.getDownKey();
      boolean _isKeyBeingHold_1 = s.isKeyBeingHold(_downKey);
      if (_isKeyBeingHold_1) {
        _xifexpression_1 = 1;
      } else {
        _xifexpression_1 = 0;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public int xVector(final DeltaState s) {
    int _xifexpression = (int) 0;
    Key _leftKey = this.getLeftKey();
    boolean _isKeyBeingHold = s.isKeyBeingHold(_leftKey);
    if (_isKeyBeingHold) {
      _xifexpression = (-1);
    } else {
      int _xifexpression_1 = (int) 0;
      Key _rightKey = this.getRightKey();
      boolean _isKeyBeingHold_1 = s.isKeyBeingHold(_rightKey);
      if (_isKeyBeingHold_1) {
        _xifexpression_1 = 1;
      } else {
        _xifexpression_1 = 0;
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public boolean isZero(final UnitVector2D v) {
    boolean _and = false;
    double _x = v.getX();
    boolean _equals = (_x == 0);
    if (!_equals) {
      _and = false;
    } else {
      double _y = v.getY();
      boolean _equals_1 = (_y == 0);
      _and = _equals_1;
    }
    return _and;
  }
}
