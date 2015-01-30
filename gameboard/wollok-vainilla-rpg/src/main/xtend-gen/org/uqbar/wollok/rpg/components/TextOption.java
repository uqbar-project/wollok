package org.uqbar.wollok.rpg.components;

import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.appearances.Label;
import java.awt.Color;
import java.awt.Font;

@SuppressWarnings("all")
public class TextOption extends GameComponent {
  public TextOption(final int x, final int y, final String text) {
    super(x, y);
    Font _font = new Font("SansSerif", Font.PLAIN, 18);
    Label _label = new Label(_font, Color.WHITE, text);
    this.setAppearance(_label);
  }
}
