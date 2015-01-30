package org.uqbar.wollok.rpg;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.MovingGameComponent;
import com.uqbar.vainilla.appearances.Appearance;
import com.uqbar.vainilla.appearances.Invisible;
import com.uqbar.vainilla.colissions.Rectangle;
import com.uqbar.vainilla.events.constants.MouseButton;
import java.awt.geom.Point2D;
import java.util.List;
import java.util.function.Consumer;
import org.eclipse.xtend.lib.Property;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Pure;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.vainilla.components.behavior.Behavior;
import org.uqbar.vainilla.components.behavior.DynamicBehavior;
import org.uqbar.vainilla.components.behavior.VainillaExtensions;
import org.uqbar.wollok.rpg.WollokObjectView;
import org.uqbar.wollok.rpg.scenes.WollokRPGScene;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class WollokMovingGameComponent extends MovingGameComponent<WollokRPGScene> implements DynamicBehavior, WollokObjectView {
  @Property
  private WollokObject _model;
  
  private List<Behavior> behaviors = CollectionLiterals.<Behavior>newArrayList();
  
  public WollokMovingGameComponent() {
    super(new Invisible(), 0, 0, 1, 1, 0);
  }
  
  public WollokMovingGameComponent(final Appearance appearance) {
    super(appearance, 0, 0, 1, 1, 0);
  }
  
  public WollokMovingGameComponent(final Appearance appearance, final double xPos, final double yPos, final int i, final int i1, final int i2) {
    super(appearance, xPos, yPos, i, i1, i2);
  }
  
  public void addBehavior(final Behavior b) {
    this.behaviors.add(b);
    b.attachedTo(this);
  }
  
  public void removeBehavior(final Behavior b) {
    this.behaviors.remove(b);
    b.removeFrom(this);
  }
  
  public Iterable<Behavior> getBehaviors() {
    return this.behaviors;
  }
  
  public double bottom() {
    double _y = this.getY();
    double _height = this.getHeight();
    return (_y + _height);
  }
  
  public double top() {
    return this.getY();
  }
  
  public double left() {
    return this.getX();
  }
  
  public double rigth() {
    double _x = this.getX();
    double _width = this.getWidth();
    return (_x + _width);
  }
  
  public double horizontalCenter() {
    double _x = this.getX();
    double _width = this.getWidth();
    double _divide = (_width / 2);
    return (_x + _divide);
  }
  
  public double verticalCenter() {
    double _y = this.getY();
    double _height = this.getHeight();
    double _divide = (_height / 2);
    return (_y + _divide);
  }
  
  public void alignCenterWith(final WollokMovingGameComponent other) {
    double _horizontalCenter = other.horizontalCenter();
    double _width = this.getWidth();
    double _divide = (_width / 2);
    double _minus = (_horizontalCenter - _divide);
    this.setX(_minus);
  }
  
  public void update(final DeltaState deltaState) {
    super.update(deltaState);
    final Consumer<Behavior> _function = new Consumer<Behavior>() {
      public void accept(final Behavior it) {
        it.update(deltaState);
      }
    };
    this.behaviors.forEach(_function);
    boolean _mousePressedOnThis = this.mousePressedOnThis(deltaState);
    if (_mousePressedOnThis) {
      this.mouseButtonPressed();
    }
  }
  
  public boolean mousePressedOnThis(final DeltaState d) {
    boolean _and = false;
    boolean _isMouseButtonPressed = d.isMouseButtonPressed(MouseButton.LEFT);
    if (!_isMouseButtonPressed) {
      _and = false;
    } else {
      Rectangle _rect = this.getRect();
      Point2D.Double _currentMousePosition = d.getCurrentMousePosition();
      boolean _contains = VainillaExtensions.contains(_rect, _currentMousePosition);
      _and = _contains;
    }
    return _and;
  }
  
  public void mouseButtonPressed() {
  }
  
  @Pure
  public WollokObject getModel() {
    return this._model;
  }
  
  public void setModel(final WollokObject model) {
    this._model = model;
  }
}
