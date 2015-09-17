package org.uqbar.project.wollok.ui.diagrams.classes.view

import org.eclipse.swt.SWT
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.Font
import org.eclipse.swt.widgets.Display

/**
 * Holds all well-kwnon instances for diagram colors.
 * 
 * @author jfernandes
 */
class ClassDiagramColors {
	
	public static val CLASS_BACKGROUND = new Color(null, 255, 229, 236)
	public static val CLASS_INNER_BORDER = new Color(null, 255, 245, 240)
	
	public static val OBJECTS_VALUE_DEFAULT = CLASS_BACKGROUND
	public static val OBJECTS_VALUE_NULL = new Color(null, 255, 255, 255)
	public static val OBJECTS_VALUE_NUMERIC_BACKGROUND = new Color(null, 224, 199, 206)
	
	// FONTS
	
	public static val SYSTEM_FONT = Display.getDefault.systemFont.fontData.get(0)
	
	public static val CLASS_NAME_FONT = new Font(Display.getDefault, SYSTEM_FONT.name, SYSTEM_FONT.height.intValue + 2, SWT.BOLD)
	public static val ABSTRACT_CLASS_NAME_FONT = new Font(Display.getDefault, SYSTEM_FONT.name, SYSTEM_FONT.height.intValue + 2, SWT.ITALIC)
	
}