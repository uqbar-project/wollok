package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.appearances.Appearance;
import com.uqbar.vainilla.appearances.Label;
import java.awt.Color;
import java.awt.Font;
import org.uqbar.vainilla.components.behavior.TimeBoxed;
import org.uqbar.wollok.rpg.WollokMovingGameComponent;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class PropertyChanged extends WollokMovingGameComponent {
  public PropertyChanged(final GameComponent component, final String fieldName, final Object oldValue, final Object newValue) {
    super(PropertyChanged.createAppearance(component, fieldName, newValue), component.getX(), component.getY(), 1, 1, 0);
    double _x = component.getX();
    double _width = component.getWidth();
    double _divide = (_width / 2);
    double _plus = (_x + _divide);
    this.alignHorizontalCenterTo(_plus);
  }
  
  public static Label createAppearance(final GameComponent component, final String fieldName, final Object newValue) {
    Font _font = new Font("SansSerif", Font.PLAIN, 18);
    return new Label(_font, Color.YELLOW, ((fieldName + " = ") + newValue), true);
  }
  
  protected void nowOnScene() {
    super.nowOnScene();
    TimeBoxed _timeBoxed = new TimeBoxed(2200);
    this.addBehavior(_timeBoxed);
  }
  
  public Label getAppearance() {
    Appearance _appearance = super.getAppearance();
    return ((Label) _appearance);
  }
  
  public void update(final DeltaState deltaState) {
    super.update(deltaState);
    double _y = this.getY();
    double _minus = (_y - 1);
    this.setY(_minus);
    Label _appearance = this.getAppearance();
    Label _appearance_1 = this.getAppearance();
    Color _color = _appearance_1.getColor();
    Color _alpha = this.alpha(_color, (-3));
    _appearance.setColor(_alpha);
  }
  
  public Color alpha(final Color color, final int alphaDelta) {
    int _red = color.getRed();
    int _green = color.getGreen();
    int _blue = color.getBlue();
    int _alpha = color.getAlpha();
    int _plus = (_alpha + alphaDelta);
    int _max = Math.max(0, _plus);
    return new Color(_red, _green, _blue, _max);
  }
}
