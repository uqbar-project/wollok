package extensions;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.Platform;

public class ExtensionManager<Extension> {

	private List<Extension> extensions;
	private String extensionPoint;
	private String extensionElement;
	private String attribute;

	public ExtensionManager(String extensionPoint, String extensionElement,
			String attribute) {
		this.extensionPoint = extensionPoint;
		this.extensionElement = extensionElement;
		this.attribute = attribute;

		extensions = this.createExtensions();
	}

	public ExtensionManager() {
		extensions = this.createExtensions();
	}

	@SuppressWarnings("unchecked")
	private List<Extension> createExtensions() {
		List<Extension> out = new ArrayList<Extension>();

		IConfigurationElement[] configurationElements = Platform
				.getExtensionRegistry().getConfigurationElementsFor(
						getExtensionPoint());

		for (IConfigurationElement element : configurationElements) {
			try {
				if (element.getName().equals(extensionElement)) {
					Object executableExtension = element
							.createExecutableExtension(attribute);
					out.add(((Extension) executableExtension));
				}
			} catch (CoreException e) {
				// TODO Skip and proccess another element?;
				e.printStackTrace();
			}
		}
		return out;
	}

	public List<Extension> getExtensions() {
		return extensions;
	}

	/**
	 * The extension point is something like: Activator.PLUGIN_ID + "." +
	 * ExtensionPointName;
	 * 
	 * @return the extension point
	 * */
	public String getExtensionPoint() {
		return extensionPoint;
	}

	/**
	 * The extension point element with the implementation class :
	 * 
	 * @return the extension element
	 * */
	public String getExtensionElement() {
		return extensionElement;
	}

}
