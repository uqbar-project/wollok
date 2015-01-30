package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.appearances.Animation;
import com.uqbar.vainilla.appearances.Appearance;
import com.uqbar.vainilla.appearances.Sprite;
import com.uqbar.vainilla.events.constants.Key;
import org.uqbar.vainilla.components.behavior.Behavior;
import org.uqbar.vainilla.components.behavior.VainillaExtensions;
import resource.Resource;

/**
 * Changes the component's appearence while it is moving.
 * It uses differente animation for each direction (up, down, left, right).
 * 
 * All animation are parsed from a single image file (a tileset)
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ChangesAppearenceMoving extends Behavior {
  private Animation downAnimation;
  
  private Animation leftAnimation;
  
  private Animation rightAnimation;
  
  private Animation upAnimation;
  
  public ChangesAppearenceMoving(final String tilesFileName, final int tileWidth, final int tileHeight, final double meanTime) {
    final Sprite tiles = Resource.getSprite(tilesFileName);
    Animation _parseAnimation = VainillaExtensions.parseAnimation(tiles, (0 * tileHeight), tileWidth, tileHeight, meanTime);
    this.downAnimation = _parseAnimation;
    Animation _parseAnimation_1 = VainillaExtensions.parseAnimation(tiles, (1 * tileHeight), tileWidth, tileHeight, meanTime);
    this.leftAnimation = _parseAnimation_1;
    Animation _parseAnimation_2 = VainillaExtensions.parseAnimation(tiles, (2 * tileHeight), tileWidth, tileHeight, meanTime);
    this.rightAnimation = _parseAnimation_2;
    Animation _parseAnimation_3 = VainillaExtensions.parseAnimation(tiles, (3 * tileHeight), tileWidth, tileHeight, meanTime);
    this.upAnimation = _parseAnimation_3;
  }
  
  public void update(final DeltaState s) {
    boolean _isKeyBeingHold = s.isKeyBeingHold(Key.UP);
    if (_isKeyBeingHold) {
      this.movingUp();
    } else {
      boolean _isKeyBeingHold_1 = s.isKeyBeingHold(Key.DOWN);
      if (_isKeyBeingHold_1) {
        this.movingDown();
      } else {
        boolean _isKeyBeingHold_2 = s.isKeyBeingHold(Key.RIGHT);
        if (_isKeyBeingHold_2) {
          this.movingRight();
        } else {
          boolean _isKeyBeingHold_3 = s.isKeyBeingHold(Key.LEFT);
          if (_isKeyBeingHold_3) {
            this.movingLeft();
          } else {
            this.idle();
          }
        }
      }
    }
  }
  
  public void movingDown() {
    this.component.setAppearance(this.downAnimation);
  }
  
  public void movingLeft() {
    this.component.setAppearance(this.leftAnimation);
  }
  
  public void movingRight() {
    this.component.setAppearance(this.rightAnimation);
  }
  
  public void movingUp() {
    this.component.setAppearance(this.upAnimation);
  }
  
  public void idle() {
    Sprite[] _sprites = this.downAnimation.getSprites();
    Appearance _get = _sprites[0];
    this.component.setAppearance(_get);
  }
}
