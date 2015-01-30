package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.appearances.Invisible;
import com.uqbar.vainilla.appearances.Label;
import java.awt.Color;
import java.awt.Font;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.vainilla.components.behavior.ChangesAppearenceMoving;
import org.uqbar.vainilla.components.behavior.FeedbackPropertyChanges;
import org.uqbar.vainilla.components.behavior.MovesWithKeyboard;
import org.uqbar.vainilla.components.behavior.StayOnScreenBehavior;
import org.uqbar.vainilla.components.behavior.TimeBoxed;
import org.uqbar.vainilla.components.collision.Collidable;
import org.uqbar.wollok.rpg.WollokMovingGameComponent;
import org.uqbar.wollok.rpg.components.SendMessageOnCollision;
import org.uqbar.wollok.rpg.scenes.WollokRPGScene;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class Coronel extends WollokMovingGameComponent implements Collidable {
  public Coronel(final WollokObject model) {
    super(new Invisible(), 30, 30, 1, 1, 0);
    this.setModel(model);
    MovesWithKeyboard _movesWithKeyboard = new MovesWithKeyboard();
    this.addBehavior(_movesWithKeyboard);
    ChangesAppearenceMoving _changesAppearenceMoving = new ChangesAppearenceMoving("coronel_tiles.png", 38, 57, 0.3);
    this.addBehavior(_changesAppearenceMoving);
    StayOnScreenBehavior _stayOnScreenBehavior = new StayOnScreenBehavior();
    this.addBehavior(_stayOnScreenBehavior);
    FeedbackPropertyChanges _feedbackPropertyChanges = new FeedbackPropertyChanges(model);
    this.addBehavior(_feedbackPropertyChanges);
    SendMessageOnCollision _sendMessageOnCollision = new SendMessageOnCollision();
    this.addBehavior(_sendMessageOnCollision);
  }
  
  public void collidesWith(final Collidable other) {
  }
  
  public void mouseButtonPressed() {
    WollokRPGScene _scene = this.getScene();
    Font _font = new Font("SansSerif", Font.PLAIN, 18);
    WollokObject _model = this.getModel();
    String _string = _model.toString();
    Label _label = new Label(_font, Color.WHITE, _string);
    WollokMovingGameComponent _wollokMovingGameComponent = new WollokMovingGameComponent(_label);
    final Procedure1<WollokMovingGameComponent> _function = new Procedure1<WollokMovingGameComponent>() {
      public void apply(final WollokMovingGameComponent it) {
        double _bottom = Coronel.this.bottom();
        double _plus = (_bottom + 5);
        it.alignTopTo(_plus);
        it.alignCenterWith(Coronel.this);
        TimeBoxed _timeBoxed = new TimeBoxed(2300);
        it.addBehavior(_timeBoxed);
      }
    };
    WollokMovingGameComponent _doubleArrow = ObjectExtensions.<WollokMovingGameComponent>operator_doubleArrow(_wollokMovingGameComponent, _function);
    _scene.addComponent(_doubleArrow);
  }
}
