package org.uqbar.project.wollok.game;

import com.badlogic.gdx.utils.Json;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

@SuppressWarnings("all")
public class GameboardFactory {
  public static void setGame(final Gameboard gameboard) {
    GameConfiguration _loadConfig = GameboardFactory.loadConfig();
    _loadConfig.configure(gameboard);
  }
  
  public static GameConfiguration loadConfig() {
    try {
      GameConfiguration _xblockexpression = null;
      {
        Json json = new Json();
        String text = GameboardFactory.readFile("config.json", StandardCharsets.UTF_8);
        _xblockexpression = json.<GameConfiguration>fromJson(GameConfiguration.class, text);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public static String readFile(final String path, final Charset encoding) throws IOException {
    Path _get = Paths.get(path);
    byte[] encoded = Files.readAllBytes(_get);
    return new String(encoded, encoding);
  }
}
