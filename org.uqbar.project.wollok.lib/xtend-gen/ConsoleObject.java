import java.io.BufferedReader;
import java.io.InputStreamReader;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.interpreter.WollokInterpreter;
import org.uqbar.project.wollok.interpreter.WollokInterpreterConsole;

@SuppressWarnings("all")
public class ConsoleObject {
  private final BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
  
  public void println(final Object obj) {
    WollokInterpreter _instance = WollokInterpreter.getInstance();
    WollokInterpreterConsole _console = _instance.getConsole();
    _console.logMessage(("" + obj));
  }
  
  public String readLine() {
    try {
      return this.reader.readLine();
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public int readInt() {
    try {
      int _xblockexpression = (int) 0;
      {
        final String line = this.reader.readLine();
        _xblockexpression = Integer.parseInt(line);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
