package org.uqbar.project.wollok.game;

import com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration;

@SuppressWarnings("all")
public class Launcher {
  private LwjglApplicationConfiguration cfg;
  
  public int launch() {
    int _xblockexpression = (int) 0;
    {
      LwjglApplicationConfiguration _lwjglApplicationConfiguration = new LwjglApplicationConfiguration();
      this.cfg = _lwjglApplicationConfiguration;
      this.cfg.title = "sokoban";
      this.cfg.useGL30 = false;
      this.cfg.width = 480;
      _xblockexpression = this.cfg.height = 320;
    }
    return _xblockexpression;
  }
}
