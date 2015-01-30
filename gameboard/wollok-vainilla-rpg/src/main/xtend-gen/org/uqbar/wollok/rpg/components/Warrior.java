package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.events.constants.Key;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.vainilla.components.behavior.MovesWithKeyboard;
import org.uqbar.vainilla.components.behavior.StayOnScreenBehavior;
import org.uqbar.wollok.rpg.WollokMovingGameComponent;
import resource.Resource;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class Warrior extends WollokMovingGameComponent {
  public Warrior() {
    super(Resource.getSprite("warrior.png"), 0, 0, 1, 1, 0);
    MovesWithKeyboard _movesWithKeyboard = new MovesWithKeyboard();
    final Procedure1<MovesWithKeyboard> _function = new Procedure1<MovesWithKeyboard>() {
      public void apply(final MovesWithKeyboard it) {
        it.setUpKey(Key.W);
        it.setDownKey(Key.S);
        it.setLeftKey(Key.A);
        it.setRightKey(Key.D);
      }
    };
    MovesWithKeyboard _doubleArrow = ObjectExtensions.<MovesWithKeyboard>operator_doubleArrow(_movesWithKeyboard, _function);
    this.addBehavior(_doubleArrow);
    StayOnScreenBehavior _stayOnScreenBehavior = new StayOnScreenBehavior();
    this.addBehavior(_stayOnScreenBehavior);
  }
  
  public void update(final DeltaState deltaState) {
    super.update(deltaState);
  }
}
