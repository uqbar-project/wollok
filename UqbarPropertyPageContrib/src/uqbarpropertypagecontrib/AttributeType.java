package uqbarpropertypagecontrib;


public interface AttributeType<Model> {

	void toModel(Model model,String attributeName, Object value);
	Object fromModel(Model model, String attributeName, Object defaultValue);
	Object getValueType();
}
