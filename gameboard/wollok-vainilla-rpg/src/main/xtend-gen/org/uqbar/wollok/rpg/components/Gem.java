package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.appearances.Animation;
import com.uqbar.vainilla.appearances.Sprite;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.vainilla.components.behavior.VainillaExtensions;
import org.uqbar.vainilla.components.collision.Collidable;
import org.uqbar.wollok.rpg.WollokObjectView;
import resource.Resource;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class Gem extends GameComponent implements Collidable, WollokObjectView {
  private WollokObject _model;
  
  public WollokObject getModel() {
    return this._model;
  }
  
  public void setModel(final WollokObject model) {
    this._model = model;
  }
  
  public Gem(final WollokObject obj) {
    this.setModel(obj);
    WollokObject _model = this.getModel();
    final Object color = _model.call("getColor");
    Sprite _sprite = Resource.getSprite((("gem_tiles_" + color) + ".png"));
    Animation _asAnimation = VainillaExtensions.asAnimation(_sprite, 0.08, 18);
    this.setAppearance(_asAnimation);
  }
  
  public void collidesWith(final Collidable other) {
  }
}
