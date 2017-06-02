package org.uqbar.project.wollok.ui.diagrams;

import java.util.Properties;

import org.eclipse.osgi.util.NLS;
import org.uqbar.project.wollok.utils.WNLS;

public class Messages extends NLS {
	private static final String BUNDLE_NAME = "org.uqbar.project.wollok.ui.diagrams.messages"; //$NON-NLS-1$

	// Toolbar actions
	public static String StaticDiagram_Export_Description;
	public static String StaticDiagram_Show_Variables;
	public static String StaticDiagram_RememberShapePositions_Description;
	public static String StaticDiagram_CleanShapePositions_Description;
	public static String StaticDiagram_SaveConfiguration_Description;
	public static String StaticDiagram_LoadConfiguration_Description;
	public static String StaticDiagram_OpenFile;
	public static String StaticDiagram_CleanAllRelationships_Description;
	public static String StaticDiagram_ShowHiddenComponents_Description;
	public static String StaticDiagram_ShowHiddenParts_Description;

	// Tool entries
	public static String StaticDiagram_CreateAssociation_Title;
	public static String StaticDiagram_CreateAssociation_Description;
	public static String StaticDiagram_CreateDependency_Title;
	public static String StaticDiagram_CreateDependency_Description;

	// Contextual menu options
	public static String StaticDiagram_DeleteFromDiagram_Description;
	
	// Relation types
	public static String RelationType_InheritanceDescription;
	public static String RelationType_AssociationDescription;
	public static String RelationType_DependencyDescription;
	
	// Error messages
	public static String StaticDiagram_Association_Not_Found;
	public static String StaticDiagram_Dependency_Not_Found;
	public static String StaticDiagram_RelationCannotBeSelfRelated;
	public static String StaticDiagram_Invalid_Relation_Type;
	public static String StaticDiagram_TargetConnectionCannotBeNull;
	
	// Info messages
	public static String StaticDiagram_UpdateDiagramView;
	
	static {
		// initialize resource bundle
		NLS.initializeMessages(BUNDLE_NAME, Messages.class);
	}
	
	public static Properties loadProperties() { return WNLS.load(BUNDLE_NAME, Messages.class); }

	private Messages() {
	}

}

