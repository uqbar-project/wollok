package uqbarpropertypagecontrib;

import java.util.ArrayList;
import java.util.List;

import javax.management.RuntimeErrorException;

import org.eclipse.core.databinding.DataBindingContext;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.eclipse.jface.layout.GridLayoutFactory;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.dialogs.PropertyPage;
import org.osgi.service.prefs.BackingStoreException;

/**
 * This class is prepared for use IEclipsePreferences, Project Scope, as backing model.
 * You can override type attributes for use another kind of backing
 * @author leo
 *
 */

public abstract class DynamicPropertyPage<Model> extends PropertyPage implements
		ModelWrapper<Model> {

	private List<PreferenceObservableValue> observablesValues = new ArrayList<PreferenceObservableValue>();
	//IEclipsePreferences or override all attributesTypesMethods 
	private Model model;
	private DataBindingContext dbc = new DataBindingContext();
	private SaveModelStrategy<Model> saveModelStrategy;

	

	public DynamicPropertyPage() {
		
	}

	public void setSaveModelStrategy(SaveModelStrategy<Model> saveModelStrategy) {
		this.saveModelStrategy = saveModelStrategy;
	}
	
	public void setModel(Model model) {
		this.model = model;
	}
	

	public PreferenceObservableValue addString(String attributeName, String description,
			String defaultValue) {
		return this.addAttribute(attributeName,
				description, defaultValue, getStringType(),
				WidgetFactories.TEXT);
	}


	public PreferenceObservableValue addAttribute(String attributeName, String description,
			Object defaultValue, AttributeType type,
			WidgetFactory widgetFactory) {
		return this.addModel(new PreferenceObservableValue(this, attributeName,
				description, defaultValue, type, widgetFactory, this
						.getDatabindingContex()));
	}

	public DataBindingContext getDatabindingContex() {
		return this.dbc;
	}
	
	public void setDatabindingContext(DataBindingContext dbc) {
		this.dbc = dbc;
	}

	public PreferenceObservableValue addBoolean(String preferenceName, String description,
			boolean defaultValue) {
		return this.addAttribute(preferenceName,
				description, defaultValue, getBooleanType(),
				WidgetFactories.CHECKBOX);

	}


	public PreferenceObservableValue addModel(PreferenceObservableValue value) {
		this.observablesValues.add(value);
		return value;
	}

	@Override
	protected Control createContents(Composite parent) {
		this.load();
		final Composite composite = new Composite(parent, SWT.NONE);
		for (PreferenceObservableValue model : observablesValues) {
			model.addTo(composite);
		}
		GridLayoutFactory.swtDefaults().generateLayout(composite);
		return composite;
	}

	public Model getModel() {
		if (this.model == null) {
			this.model = createModel();
		}
		return this.model;
	}



	protected Model createModel() {
		return null;
	}



	public void load() {
		for (PreferenceObservableValue model : this.observablesValues) {
			model.fromPreference();
		}
	}

	@Override
	public boolean performOk() {
		for (PreferenceObservableValue model : this.observablesValues) {
			model.toPreference();
		}
		save();
		return super.performOk();
	}

	protected void save() {
		if(this.saveModelStrategy != null) {
			this.saveModelStrategy.save(this.getModel());
		}
	}

	@Override
	protected void performDefaults() {
		for (PreferenceObservableValue model : this.observablesValues) {
			model.restoreDefault();
		}
		super.performDefaults();
	}
	
	protected abstract AttributeType<Model> getBooleanType();
	
	protected abstract AttributeType<Model> getStringType();
	

}
