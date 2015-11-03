package uqbarpropertypagecontrib;



import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.databinding.observable.value.AbstractObservableValue;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.observable.value.ValueDiff;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.swt.widgets.Composite;

public class PreferenceObservableValue extends AbstractObservableValue {

	private ModelWrapper preferencesWrapper;
	
	private String preferenceName;
	private String description;
	private Object defaultValue;
	
	private AttributeType preferenceType;
	private Object value;
	private WidgetFactory widgetFactory;
	private DataBindingContext context;
	private IObservableValue enableWhen; 
	
	public Object getModel() {
		return this.preferencesWrapper.getModel();
	}

	public void enableWhen(IObservableValue booleanObserver) {
		this.setEnableWhen(booleanObserver);
	}
	
	public void disableWhen(IObservableValue booleanObserver) {
		this.enableWhen(new NotObservableValue(booleanObserver, true));		
	}

	public ModelWrapper getPreferencesWrapper() {
		return preferencesWrapper;
	}

	public void setPreferencesWrapper(ModelWrapper preferencesWrapper) {
		this.preferencesWrapper = preferencesWrapper;
	}


	public String getPreferenceName() {
		return preferenceName;
	}

	public void setPreferenceName(String preferenceName) {
		this.preferenceName = preferenceName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String descriptionName) {
		this.description = descriptionName;
	}

	public Object getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(Object defaultValue) {
		this.defaultValue = defaultValue;
	}

	public AttributeType getPreferenceType() {
		return preferenceType;
	}

	public void setPreferenceType(AttributeType preferenceType) {
		this.preferenceType = preferenceType;
	}

	public WidgetFactory getWidgetFactory() {
		return widgetFactory;
	}

	public void setWidgetFactory(WidgetFactory widgetFactory) {
		this.widgetFactory = widgetFactory;
	}


	public PreferenceObservableValue(
			ModelWrapper preferenceWrapper, String preferenceName,
			String descriptionName, Object defaultValue,
			AttributeType preferenceType, 
			WidgetFactory widgetFactory, DataBindingContext context) {
		super();
		this.preferencesWrapper = preferenceWrapper;
		this.preferenceName = preferenceName;
		this.description = descriptionName;
		this.defaultValue = defaultValue;
		this.preferenceType = preferenceType;
		this.widgetFactory = widgetFactory;
		this.context = context;
	}

	public DataBindingContext getContext() {
		return context;
	}

	public void setContext(DataBindingContext context) {
		this.context = context;
	}

	@Override
	protected void doSetValue(final Object value) {
		final Object oldValue = this.value;
		this.value = value;
		this.fireValueChange(new ValueDiff() {
			
			@Override
			public Object getOldValue() {
				return oldValue;
			}
			
			@Override
			public Object getNewValue() {
				return value;
			}
		});
	}
	@Override
	public Object getValueType() {
		return this.preferenceType.getValueType();
	}

	public void addTo(Composite composite) {
		this.widgetFactory.addTo(composite, this);
	}

	@Override
	public Object doGetValue() {
		return value;
	}
	
	public void toPreference() {
		this.preferenceType.toModel(this.preferencesWrapper.getModel(), this.preferenceName, this.getValue() != null ? this.getValue() : this.defaultValue);
	}
	
	public void fromPreference() {
		this.setValue(this.preferenceType.fromModel(this.preferencesWrapper.getModel(), this.preferenceName, this.defaultValue));
	} 
	
	public void restoreDefault() {
		this.setValue(defaultValue);
	}

	public IObservableValue getEnableWhen() {
		return enableWhen;
	}

	public void setEnableWhen(IObservableValue disableOn) {
		this.enableWhen = disableOn;
	}
	
}
