package org.uqbar.project.wollok.ui.console.highlight;

import static org.uqbar.project.wollok.ui.console.highlight.AnsiCommands.COMMAND_COLOR_INTENSITY_DELTA;

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.RGB;
import static org.uqbar.project.wollok.ui.console.highlight.WollokConsoleColorPalette.*
import static org.uqbar.project.wollok.ui.console.highlight.WollokConsolePreferenceUtils.*


/**
 * 
 * @author jfernandes
 */
class WollokConsoleAttributes implements Cloneable {
    public static val UNDERLINE_NONE = -1; // nothing in SWT, a bit of an abuse

    public Integer currentBgColor
    public Integer currentFgColor
    public var underline = UNDERLINE_NONE
    public var bold = false
    public var italic = false
    public var invert = false
    public var conceal = false
    public var strike = false
    public var framed = false

    new() {
        reset
    }

    def reset() {
        currentBgColor = null
        currentFgColor = null
    }

    override WollokConsoleAttributes clone() {
        new WollokConsoleAttributes => [
	        it.currentBgColor = this.currentBgColor
	        it.currentFgColor = this.currentFgColor
	        it.underline = this.underline
	        it.bold = this.bold
	        it.italic = this.italic
	        it.invert = this.invert
	        it.conceal = this.conceal
	        it.strike = this.strike
	        it.framed = this.framed
        ]
    }

    def static hiliteRgbColor(Color it) {
        if (it === null)
            return new RGB(0xff, 0xff, 0xff).color
		
        new RGB((red * 2).safe, (green * 2).safe, (blue * 2).safe).color
    }
    
    def static safe(int i) { if (i > 0xff) 0xff else i }
    def static color(RGB it) { new Color(null, it) }

    // This function maps from the current attributes as "described" by escape sequences to real,
    // Eclipse console specific attributes (resolving color palette, default colors, etc.)
    def static updateRangeStyle(StyleRange range, WollokConsoleAttributes attribute) {
        val useWindowsMapping = getBoolean(WollokConsolePreferenceConstants.PREF_WINDOWS_MAPPING)
        val WollokConsoleAttributes tempAttrib = attribute.clone as WollokConsoleAttributes

        var hilite = false

        if (useWindowsMapping) {
            if (tempAttrib.bold) {
                tempAttrib.bold = false // not supported, rendered as intense, already done that
                hilite = true
            }
            if (tempAttrib.italic) {
                tempAttrib.italic = false
                tempAttrib.invert = true
            }
            tempAttrib.underline = UNDERLINE_NONE // not supported on Windows
            tempAttrib.strike = false // not supported on Windows
            tempAttrib.framed = false // not supported on Windows
        }

        // Prepare the foreground color
        if (hilite) {
            if (tempAttrib.currentFgColor === null) {
                range.foreground = getDebugConsoleFgColor
                range.foreground = hiliteRgbColor(range.foreground)
            } else {
                range.foreground = if (tempAttrib.currentFgColor < COMMAND_COLOR_INTENSITY_DELTA)
                    	 getColor(tempAttrib.currentFgColor + COMMAND_COLOR_INTENSITY_DELTA).color
                	else
                    	getColor(tempAttrib.currentFgColor).color
            }
        } else {
            if (tempAttrib.currentFgColor !== null)
                range.foreground = getColor(tempAttrib.currentFgColor).color
        }

        // Prepare the background color
        if (tempAttrib.currentBgColor !== null)
            range.background = getColor(tempAttrib.currentBgColor).color

        // These two still mess with the foreground/background colors
        // We need to solve them before we use them for strike/underline/frame colors
        if (tempAttrib.invert) {
            if (range.foreground === null)
                range.foreground = getDebugConsoleFgColor
            if (range.background === null)
                range.background = getDebugConsoleBgColor
            val tmp = range.background
            range.background = range.foreground
            range.foreground = tmp
        }

        if (tempAttrib.conceal) {
            if (range.background === null)
                range.background = getDebugConsoleBgColor
            range.foreground = range.background
        }

        range.font = null
        range.fontStyle = SWT.NORMAL
        // Prepare the rest of the attributes
        if (tempAttrib.bold)
            range.fontStyle = range.fontStyle.bitwiseOr(SWT.BOLD)

        if (tempAttrib.italic)
            range.fontStyle = range.fontStyle.bitwiseOr(SWT.ITALIC)

        if (tempAttrib.underline != UNDERLINE_NONE) {
            range.underline = true
            range.underlineColor = range.foreground
            range.underlineStyle = tempAttrib.underline
        }
        else
            range.underline = false

        range.strikeout = tempAttrib.strike
        range.strikeoutColor = range.foreground

        if (tempAttrib.framed) {
            range.borderStyle = SWT.BORDER_SOLID
            range.borderColor = range.foreground
        }
        else
            range.borderStyle = SWT.NONE
    }
}