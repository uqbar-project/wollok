package org.uqbar.project.wollok.ui.console.highlight

import org.eclipse.core.runtime.Platform
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB
import org.uqbar.project.wollok.ui.launch.Activator

/**
 * 
 * @author jfernandes
 */
class WollokConsolePreferenceUtils {
    static val DEBUG_CONSOLE_PLUGIN_ID        = "org.eclipse.debug.ui";
    static val DEBUG_CONSOLE_FALLBACK_BKCOLOR = "0,0,0";
    static val DEBUG_CONSOLE_FALLBACK_FGCOLOR = "192,192,192";

    def static colorFromStringRgb(String strRgb) {
        val splitted = strRgb.split(",")
        if (splitted !== null && splitted.length == 3) {
            val red = tryParseInteger(splitted.get(0))
            val green = tryParseInteger(splitted.get(1))
            val blue = tryParseInteger(splitted.get(2))
            return new Color(null, new RGB(red, green, blue))
        }
        null
    }

    def static getBoolean(String name) { preferences.getBoolean(name) }
    def static getString(String name) { preferences.getString(name) }
    def static preferences() { Activator.getDefault.preferenceStore }

    def static prefGetColor(String id) { getString(id).colorFromStringRgb }

    def static getDebugConsoleBgColor() { getColor("org.eclipse.debug.ui.consoleBackground", DEBUG_CONSOLE_FALLBACK_BKCOLOR) }
    def static getDebugConsoleFgColor() { getColor("org.eclipse.debug.ui.outColor", DEBUG_CONSOLE_FALLBACK_FGCOLOR) }
    
    def static getColor(String a, String b) {
        return Platform.getPreferencesService.getString(DEBUG_CONSOLE_PLUGIN_ID, a, b, null).colorFromStringRgb
    }

    def static tryParseInteger(String text) {
        try
        	if ("" == text)
            	-1
            else
            	Integer.parseInt(text)
        catch (NumberFormatException e)
            -1
    }

    def static setValue(String name, boolean value) { preferences.setValue(name, value) }
}