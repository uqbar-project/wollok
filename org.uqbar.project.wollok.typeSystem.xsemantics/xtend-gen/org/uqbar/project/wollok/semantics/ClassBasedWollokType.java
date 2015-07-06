package org.uqbar.project.wollok.semantics;

import com.google.common.base.Objects;
import it.xsemantics.runtime.Result;
import it.xsemantics.runtime.RuleEnvironment;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.uqbar.project.wollok.model.WMethodContainerExtensions;
import org.uqbar.project.wollok.model.WollokModelExtensions;
import org.uqbar.project.wollok.semantics.BasicType;
import org.uqbar.project.wollok.semantics.ConcreteType;
import org.uqbar.project.wollok.semantics.MessageType;
import org.uqbar.project.wollok.semantics.ObjectLiteralWollokType;
import org.uqbar.project.wollok.semantics.StructuralType;
import org.uqbar.project.wollok.semantics.TypeSystemException;
import org.uqbar.project.wollok.semantics.WollokDslTypeSystem;
import org.uqbar.project.wollok.semantics.WollokType;
import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.project.wollok.wollokDsl.WParameter;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class ClassBasedWollokType extends BasicType implements ConcreteType {
  private WClass clazz;
  
  private WollokDslTypeSystem system;
  
  private RuleEnvironment env;
  
  public ClassBasedWollokType(final WClass clazz, final WollokDslTypeSystem system, final RuleEnvironment env) {
    super(clazz.getName());
    this.clazz = clazz;
    this.system = system;
    this.env = env;
  }
  
  public boolean understandsMessage(final MessageType message) {
    WMethodDeclaration _lookupMethod = this.lookupMethod(message);
    return (!Objects.equal(_lookupMethod, null));
  }
  
  public void acceptAssignment(final WollokType other) {
    boolean _or = false;
    boolean _equals = Objects.equal(this, other);
    if (_equals) {
      _or = true;
    } else {
      boolean _and = false;
      if (!(other instanceof ClassBasedWollokType)) {
        _and = false;
      } else {
        boolean _isSuperTypeOf = WollokModelExtensions.isSuperTypeOf(this.clazz, ((ClassBasedWollokType) other).clazz);
        _and = _isSuperTypeOf;
      }
      _or = _and;
    }
    final boolean value = _or;
    if ((!value)) {
      StringConcatenation _builder = new StringConcatenation();
      _builder.append("<<");
      _builder.append(other, "");
      _builder.append(">> is not a valid substitude for <<");
      _builder.append(this, "");
      _builder.append(">>");
      throw new TypeSystemException(_builder.toString());
    }
  }
  
  public WMethodDeclaration lookupMethod(final MessageType message) {
    WMethodDeclaration _xblockexpression = null;
    {
      String _name = message.getName();
      final WMethodDeclaration m = WMethodContainerExtensions.lookupMethod(this.clazz, _name);
      WMethodDeclaration _xifexpression = null;
      boolean _and = false;
      boolean _notEquals = (!Objects.equal(m, null));
      if (!_notEquals) {
        _and = false;
      } else {
        EList<WParameter> _parameters = m.getParameters();
        int _size = _parameters.size();
        List<WollokType> _parameterTypes = message.getParameterTypes();
        int _size_1 = _parameterTypes.size();
        boolean _equals = (_size == _size_1);
        _and = _equals;
      }
      if (_and) {
        _xifexpression = m;
      } else {
        _xifexpression = null;
      }
      _xblockexpression = _xifexpression;
    }
    return _xblockexpression;
  }
  
  public WollokType resolveReturnType(final MessageType message, final WollokDslTypeSystem system, final RuleEnvironment g) {
    WollokType _xblockexpression = null;
    {
      final WMethodDeclaration method = this.lookupMethod(message);
      _xblockexpression = system.<WollokType>env(g, method, WollokType.class);
    }
    return _xblockexpression;
  }
  
  public WollokType refine(final WollokType previouslyInferred, final RuleEnvironment g) {
    return this.doRefine(previouslyInferred, g);
  }
  
  protected WollokType _doRefine(final WollokType previous, final RuleEnvironment g) {
    return super.refine(previous, g);
  }
  
  protected WollokType _doRefine(final ClassBasedWollokType previous, final RuleEnvironment g) {
    ClassBasedWollokType _xblockexpression = null;
    {
      final WClass commonType = this.commonSuperclass(this.clazz, previous.clazz);
      boolean _equals = Objects.equal(commonType, null);
      if (_equals) {
        String _name = previous.getName();
        String _plus = ("Incompatible types. Expected " + _name);
        String _plus_1 = (_plus + " <=> ");
        String _name_1 = this.getName();
        String _plus_2 = (_plus_1 + _name_1);
        throw new TypeSystemException(_plus_2);
      }
      _xblockexpression = new ClassBasedWollokType(commonType, this.system, this.env);
    }
    return _xblockexpression;
  }
  
  protected WollokType _doRefine(final ObjectLiteralWollokType previous, final RuleEnvironment g) {
    StructuralType _xblockexpression = null;
    {
      Iterable<MessageType> _allMessages = this.getAllMessages(g);
      final Function1<MessageType, Boolean> _function = new Function1<MessageType, Boolean>() {
        public Boolean apply(final MessageType it) {
          return Boolean.valueOf(previous.understandsMessage(it));
        }
      };
      final Iterable<MessageType> intersectMessages = IterableExtensions.<MessageType>filter(_allMessages, _function);
      Iterator<MessageType> _iterator = intersectMessages.iterator();
      _xblockexpression = new StructuralType(_iterator);
    }
    return _xblockexpression;
  }
  
  public WClass commonSuperclass(final WClass a, final WClass b) {
    WClass _xifexpression = null;
    boolean _isSubclassOf = this.isSubclassOf(a, b);
    if (_isSubclassOf) {
      _xifexpression = b;
    } else {
      WClass _xifexpression_1 = null;
      boolean _isSubclassOf_1 = this.isSubclassOf(b, a);
      if (_isSubclassOf_1) {
        _xifexpression_1 = a;
      } else {
        WClass _parent = a.getParent();
        WClass _parent_1 = b.getParent();
        _xifexpression_1 = this.commonSuperclass(_parent, _parent_1);
      }
      _xifexpression = _xifexpression_1;
    }
    return _xifexpression;
  }
  
  public boolean isSubclassOf(final WClass potSub, final WClass potSuper) {
    boolean _or = false;
    boolean _equals = Objects.equal(potSub, potSuper);
    if (_equals) {
      _or = true;
    } else {
      boolean _and = false;
      boolean _noneAreNull = XTendUtilExtensions.noneAreNull(potSub, potSuper);
      if (!_noneAreNull) {
        _and = false;
      } else {
        WClass _parent = potSub.getParent();
        boolean _isSubclassOf = this.isSubclassOf(_parent, potSuper);
        _and = _isSubclassOf;
      }
      _or = _and;
    }
    return _or;
  }
  
  public Iterable<MessageType> getAllMessages() {
    return this.getAllMessages(this.env);
  }
  
  public Iterable<MessageType> getAllMessages(final RuleEnvironment g) {
    Iterable<WMethodDeclaration> _allMethods = WMethodContainerExtensions.allMethods(this.clazz);
    final Function1<WMethodDeclaration, MessageType> _function = new Function1<WMethodDeclaration, MessageType>() {
      public MessageType apply(final WMethodDeclaration m) {
        Result<MessageType> _queryMessageTypeForMethod = ClassBasedWollokType.this.system.queryMessageTypeForMethod(g, m);
        return _queryMessageTypeForMethod.getFirst();
      }
    };
    return IterableExtensions.<WMethodDeclaration, MessageType>map(_allMethods, _function);
  }
  
  public boolean equals(final Object obj) {
    boolean _and = false;
    if (!(obj instanceof ClassBasedWollokType)) {
      _and = false;
    } else {
      boolean _equals = Objects.equal(((ClassBasedWollokType) obj).clazz, this.clazz);
      _and = _equals;
    }
    return _and;
  }
  
  public int hashCode() {
    return this.clazz.hashCode();
  }
  
  public WollokType doRefine(final WollokType previous, final RuleEnvironment g) {
    if (previous instanceof ClassBasedWollokType) {
      return _doRefine((ClassBasedWollokType)previous, g);
    } else if (previous instanceof ObjectLiteralWollokType) {
      return _doRefine((ObjectLiteralWollokType)previous, g);
    } else if (previous != null) {
      return _doRefine(previous, g);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(previous, g).toString());
    }
  }
}
