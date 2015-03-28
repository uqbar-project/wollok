import com.google.common.base.Objects;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.uqbar.project.wollok.interpreter.nativeobj.AbstractWollokDeclarativeNativeObject;
import org.uqbar.project.wollok.interpreter.nativeobj.NativeMessage;
import org.uqbar.project.wollok.interpreter.operation.WollokBasicBinaryOperations;
import org.uqbar.project.wollok.interpreter.operation.WollokDeclarativeNativeBasicOperations;

@SuppressWarnings("all")
public class TesterObject extends AbstractWollokDeclarativeNativeObject {
  @Extension
  private WollokBasicBinaryOperations _wollokBasicBinaryOperations = new WollokDeclarativeNativeBasicOperations();
  
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
  
  protected void _assertEquals(final Object a, final Object b) {
    try {
      Function2<? super Object, ? super Object, ?> _asBinaryOperation = this._wollokBasicBinaryOperations.asBinaryOperation("!=");
      Object _apply = _asBinaryOperation.apply(a, b);
      boolean _equals = Objects.equal(_apply, Boolean.valueOf(true));
      if (_equals) {
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
  
  public void assertEquals(final Object a, final Object b) {
    _assertEquals(a, b);
    return;
  }
}
