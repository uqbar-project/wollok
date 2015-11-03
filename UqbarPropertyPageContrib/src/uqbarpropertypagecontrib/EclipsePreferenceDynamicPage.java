package uqbarpropertypagecontrib;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ProjectScope;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.IScopeContext;
import org.osgi.service.prefs.BackingStoreException;

public abstract class EclipsePreferenceDynamicPage extends DynamicPropertyPage<IEclipsePreferences> {
	
	protected IEclipsePreferences buildPreference() {
		IScopeContext projectScope = buildScopeContext();
		return projectScope.getNode(getPluginId());
	}

	@Override
	protected IEclipsePreferences createModel() {
		this.setSaveModelStrategy(new SaveModelStrategy<IEclipsePreferences>() {
			@Override
			public void save(IEclipsePreferences model) {
				try {
					model.flush();
				} catch (BackingStoreException e) {
					throw new RuntimeException(e);
				}
			}
		});
		return buildPreference();
	}

	protected AttributeType<IEclipsePreferences> getBooleanType() {
		return PreferenceTypes.BOOLEAN;
	}

	@Override
	protected AttributeType<IEclipsePreferences> getStringType() {
		return PreferenceTypes.STRING;
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

}
