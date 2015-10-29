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

public abstract class DynamicPropertyPage extends PropertyPage implements
		IEclipsePreferenceWrapper {

	private List<PreferenceObservableValue> models = new ArrayList<PreferenceObservableValue>();
	private IEclipsePreferences preferences;
	private DataBindingContext dbc = new DataBindingContext();

	public void setPreferences(IEclipsePreferences preferences) {
		this.preferences = preferences;
	}

	public DynamicPropertyPage() {
		
	}
	

	public PreferenceObservableValue addString(String preferenceName, String description,
			String defaultValue) {
		return this.addModel(preferenceName,
				description, defaultValue, PreferenceTypes.STRING,
				WidgetFactories.TEXT);
	}

	public PreferenceObservableValue addModel(String preferenceName, String description,
			Object defaultValue, PreferenceType type,
			WidgetFactory widgetFactory) {
		return this.addModel(new PreferenceObservableValue(this, preferenceName,
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
		return this.addModel(preferenceName,
				description, defaultValue, PreferenceTypes.BOOLEAN,
				WidgetFactories.CHECKBOX);

	}

	public PreferenceObservableValue addModel(PreferenceObservableValue value) {
		this.models.add(value);
		return value;
	}

	@Override
	protected Control createContents(Composite parent) {
		this.load();
		final Composite composite = new Composite(parent, SWT.NONE);
		for (PreferenceObservableValue model : models) {
			model.addTo(composite);
		}
		GridLayoutFactory.swtDefaults().generateLayout(composite);
		return composite;
	}

	public IEclipsePreferences getPreferences() {
		if (this.preferences == null) {
			this.preferences = buildPreference();
		}
		return this.preferences;
	}

	protected IEclipsePreferences buildPreference() {
		IScopeContext projectScope = buildScopeContext();
		return projectScope.getNode(getPluginId());
	}

	/**
	 * Create preference for project scope. Override it if you want other scope
	 * */
	protected IScopeContext buildScopeContext() {
		return new ProjectScope((IProject) this
				.getElement().getAdapter(IProject.class));
	}

	/**
	 * Used by buildPreference method to define scope in a Plugin context a
	 * typical implementation return Activator.PLUGIN_ID
	 */
	protected abstract String getPluginId();

	public void load() {
		for (PreferenceObservableValue model : this.models) {
			model.fromPreference();
		}
	}

	@Override
	public boolean performOk() {
		for (PreferenceObservableValue model : this.models) {
			model.toPreference();
		}
		try {
			this.getPreferences().flush();
		} catch (BackingStoreException e) {
			throw new RuntimeException(e);
		}
		return super.performOk();
	}

	@Override
	protected void performDefaults() {
		for (PreferenceObservableValue model : this.models) {
			model.restoreDefault();
		}
		super.performDefaults();
	}
	
	

}
