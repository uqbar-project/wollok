package uqbarpropertypagecontrib;

import org.eclipse.core.databinding.observable.value.DecoratingObservableValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;

public class NotObservableValue extends DecoratingObservableValue {

	public NotObservableValue(IObservableValue decorated,
			boolean disposeDecoratedOnDispose) {
		super(decorated, disposeDecoratedOnDispose);
	}
	
	@Override
	public Object getValue() {
		return !(Boolean)super.getValue();
	}
	
	@Override
	public void setValue(Object value) {
		super.setValue(!(Boolean)value);
	}

}
