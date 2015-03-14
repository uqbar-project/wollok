import com.google.common.base.Objects;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject;
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage;

@SuppressWarnings("all")
public class TesterObject extends AbstractWollokDeclarativeNativeObject {
  @NativeMessage("assert")
  public void assertMethod(final Boolean value) {
    try {
      if ((!(value).booleanValue())) {
        throw new AssertionError("Value was not true");
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void assertFalse(final Boolean value) {
    try {
      if ((value).booleanValue()) {
        throw new AssertionError("Value was not false");
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void assertEquals(final Object a, final Object b) {
    try {
      boolean _notEquals = (!Objects.equal(a, b));
      if (_notEquals) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("Expected [");
        _builder.append(a, "");
        _builder.append("] but found [");
        _builder.append(b, "");
        _builder.append("]");
        throw new AssertionError(_builder);
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
