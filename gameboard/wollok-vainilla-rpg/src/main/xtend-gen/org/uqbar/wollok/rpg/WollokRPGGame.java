package org.uqbar.wollok.rpg;

import com.uqbar.vainilla.DesktopGameLauncher;
import com.uqbar.vainilla.Game;
import java.awt.Dimension;
import org.uqbar.wollok.rpg.scenes.WollokRPGScene;

/**
 * Vainilla's implementation of a wollok
 * board for rpg-like games.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class WollokRPGGame extends Game {
  private Dimension dimension;
  
  public void initializeResources() {
    Dimension _dimension = new Dimension(720, 480);
    this.dimension = _dimension;
  }
  
  public void setUpScenes() {
    WollokRPGScene _wollokRPGScene = new WollokRPGScene(this);
    this.setCurrentScene(_wollokRPGScene);
  }
  
  public Dimension getDisplaySize() {
    return this.dimension;
  }
  
  public String getTitle() {
    return "Wollok RPG Board";
  }
  
  public static void main(final String[] args) throws Exception {
    WollokRPGGame _wollokRPGGame = new WollokRPGGame();
    DesktopGameLauncher _desktopGameLauncher = new DesktopGameLauncher(_wollokRPGGame);
    _desktopGameLauncher.launch();
  }
}
