package uqbarpropertypagecontrib;

import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.jface.databinding.swt.SWTObservables;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

public enum WidgetFactories implements WidgetFactory{
	TEXT {

		@Override
		public void addTo(Composite composite,
				PreferenceObservableValue preferenceObservableValue) {

				Label label = new Label(composite, SWT.NONE);
				Text text = new Text(composite, SWT.BORDER);
				label.setText(preferenceObservableValue.getDescription());
				IObservableValue modelObservable = preferenceObservableValue;
				DataBindingContext dbc = preferenceObservableValue.getContext();
				dbc.bindValue(SWTObservables.observeText(text, SWT.Modify), modelObservable, null, null);
				
				if(preferenceObservableValue.getEnableWhen() != null) {
					IObservableValue disableModelObservable = preferenceObservableValue.getEnableWhen();
					dbc.bindValue(SWTObservables.observeEnabled(text), disableModelObservable, null, null);
				}
			}
			
		}, CHECKBOX {

			@Override
			public void addTo(Composite composite,
					PreferenceObservableValue preferenceObservableValue) {

				// TODO Auto-generated method stub
				Label label = new Label(composite, SWT.NONE);
				Button button = new Button(composite, SWT.CHECK);
				label.setText(preferenceObservableValue.getDescription());
				IObservableValue modelObservable = preferenceObservableValue;
				preferenceObservableValue.getContext().bindValue(SWTObservables.observeSelection(button), modelObservable,
						null, null);

				
			}
			
		}

}
