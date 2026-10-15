pragma Singleton
import QtQuick
import QtCore

QtObject {
    id: theme
    
    // ===== SETTINGS PERSISTENCE =====
    property Settings settings: Settings {
        category: "LogosDesignSystem"
        property string theme: "dark"
        // User's density choice; "" follows the theme (else comfortable).
        property string density: ""
    }
    
    // ===== RAW COLOR PALETTE (Design Tokens) =====
    // Single source of truth; passed to all themes
    readonly property ColorPalette colors: ColorPalette {}
    
    // ===== DESIGN TOKENS =====
    readonly property Spacing spacing: Spacing {
        radiusOverrides: theme._activeRadius.overrides
        radiusScale: theme._activeRadius.scale
    }

    // radius block of the active installed theme, split into per-step
    // overrides and the overall scale (defaults for built-in dark).
    readonly property var _activeRadius: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i) {
            if (installed[i].id !== currentTheme)
                continue
            var r = installed[i].radius || {}
            var overrides = {}
            for (var k in r)
                if (k !== "scale")
                    overrides[k] = r[k]
            return { overrides: overrides, scale: r.scale !== undefined ? r.scale : 1.0 }
        }
        return { overrides: {}, scale: 1.0 }
    }
    readonly property Typography typography: Typography {
        familyOverride: theme._activeTypography.family || ""
        monoOverride: theme._activeTypography.monoFamily || ""
    }

    // typography block of the active installed theme ({} for built-in dark).
    readonly property var _activeTypography: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return installed[i].typography || {}
        return {}
    }
    
    // gradients block of the active installed theme: slot -> spec, {} for
    // built-in dark. Draw them with LogosSurface { slot: "..." }.
    readonly property var gradients: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return installed[i].gradients || {}
        return {}
    }

    // backgrounds of the active installed theme: slot -> { url, fit, opacity,
    // tint, tintStrength } (tint already raised for readable text).
    readonly property var backgrounds: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return installed[i].backgroundSpecs || {}
        return {}
    }

    // Hover glow of the active installed theme ({ color, blur, spread,
    // opacity }), or null: built-in dark has none. Draw it with LogosGlow.
    readonly property var hoverGlow: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return (installed[i].effects && installed[i].effects.hoverGlow) || null
        return null
    }

    // ===== COMPONENT TOKENS & DENSITY =====
    // Per-control sizes and styles. Defaults are today's literals, so the
    // built-in look is unchanged; a theme's `components` block overrides them
    // and `density` scales heights and paddings (touch keeps 44 px targets).
    readonly property var _activeEntry: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return installed[i]
        return null
    }
    readonly property string density:
        settings.density !== "" ? settings.density
        : (_activeEntry && _activeEntry.density) ? _activeEntry.density : "comfortable"
    readonly property real densityScale:
        density === "compact" ? 0.85 : density === "touch" ? 1.2 : 1.0

    function setDensity(value) { settings.density = value }

    function _size(px) {
        var v = Math.round(px * densityScale)
        return density === "touch" ? Math.max(44, v) : v
    }
    function _pad(px) { return Math.round(px * densityScale) }

    readonly property var components: {
        var o = (_activeEntry && _activeEntry.components) || {}
        function pick(group, key, fallback) {
            return o[group] && o[group][key] !== undefined ? o[group][key] : fallback
        }
        var r = spacing.roundness
        return {
            button: {
                height: _size(pick("button", "height", 44)),
                compactHeight: _size(pick("button", "compactHeight", 32)),
                paddingX: _pad(pick("button", "paddingX", spacing.large)),
                compactPaddingX: _pad(spacing.medium),
                radius: o.button && o.button.radius !== undefined ? o.button.radius * r : spacing.radiusXlarge,
                borderWidth: pick("button", "borderWidth", 1)
            },
            field: {
                height: _size(pick("field", "height", 40)),
                paddingX: _pad(pick("field", "paddingX", 12)),
                radius: o.field && o.field.radius !== undefined ? o.field.radius * r : spacing.radiusSmall,
                borderWidth: pick("field", "borderWidth", 1)
            },
            search: {
                height: _size(pick("search", "height", 54)),
                radius: o.search && o.search.radius !== undefined ? o.search.radius * r : spacing.radiusLarge,
                borderWidth: pick("search", "borderWidth", 1)
            },
            combo: {
                height: _size(pick("combo", "height", 32)),
                radius: o.combo && o.combo.radius !== undefined ? o.combo.radius * r : spacing.radiusSmall,
                borderWidth: pick("combo", "borderWidth", 1)
            },
            listItem: { height: _size(pick("listItem", "height", 36)), paddingX: _pad(pick("listItem", "paddingX", spacing.medium)) },
            menuItem: { height: _size(pick("menuItem", "height", 32)), paddingX: _pad(pick("menuItem", "paddingX", spacing.medium)) },
            tab: { height: _size(pick("tab", "height", 40)), paddingX: _pad(pick("tab", "paddingX", 8)) },
            toolButton: { size: _size(pick("toolButton", "size", 36)) },
            iconButton: { size: _size(pick("iconButton", "size", 40)) },
            card: {
                radius: o.card && o.card.radius !== undefined ? o.card.radius * r : -1,   // -1: the card's own default
                borderWidth: pick("card", "borderWidth", 0),
                shadowColor: pick("card", "shadowColor", "transparent"),
                shadowBlur: pick("card", "shadowBlur", 0),
                shadowOffsetY: pick("card", "shadowOffsetY", 0),
                shadowOpacity: pick("card", "shadowOpacity", 0)
            }
        }
    }

    // icon pack of the active installed theme: name -> sanitised data: URL.
    readonly property var icons: {
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            if (installed[i].id === currentTheme)
                return installed[i].iconUrls || {}
        return {}
    }

    // The theme's replacement for icon `name`, else `fallback` (the bundled one).
    function iconOr(name, fallback) {
        var url = icons[name]
        return url ? url : fallback
    }

    // ===== THEME INSTANCES =====
    // Currently available themes - created first
    property var darkTheme: DarkTheme { colors: theme.colors }
    // Add new theme instances here as needed
    
    // ===== INSTALLED THEMES =====
    // Data-only theme packages discovered on disk (see ThemeRegistry.h).
    // Each one is layered over darkTheme token by token, so a theme that
    // leaves a token out gets the default rather than an unset colour.
    function _resolvePalette(entry) {
        var resolved = {}
        var tokens = ThemeRegistry.paletteTokens
        for (var i = 0; i < tokens.length; ++i) {
            var token = tokens[i]
            resolved[token] = entry.palette[token] !== undefined
                ? entry.palette[token] : darkTheme[token]
        }
        return resolved
    }

    // id -> { id, name, author, mode, builtin }
    readonly property var themeInfo: {
        var info = { "dark": { id: "dark", name: "Dark", author: "Logos", mode: "dark", builtin: true } }
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i) {
            var t = installed[i]
            info[t.id] = { id: t.id, name: t.name, author: t.author, mode: t.mode, builtin: false,
                           family: (t.typography && t.typography.family) || "",
                           monoFamily: (t.typography && t.typography.monoFamily) || "" }
        }
        return info
    }

    // ===== AVAILABLE THEMES =====
    property var availableThemes: {
        var themes = { "dark": darkTheme }
        var installed = ThemeRegistry.themes
        for (var i = 0; i < installed.length; ++i)
            themes[installed[i].id] = _resolvePalette(installed[i])
        return themes
    }

    // The stored choice if it is still installed, else the default. The
    // setting itself is left alone so a temporarily missing theme comes back.
    // ThemeRegistry.current is shared by every engine in the process, so a
    // change made anywhere restyles every view live; `settings` persists it.
    readonly property string currentTheme:
        availableThemes[ThemeRegistry.current] ? ThemeRegistry.current : "dark"

    // ===== CURRENT THEME (Semantic Palette) =====
    readonly property var palette: availableThemes[currentTheme]

    // ===== CONVENIENCE PROPERTIES =====
    readonly property bool isDark: themeInfo[currentTheme].mode === "dark"
    readonly property var themeNames: Object.keys(availableThemes)
    
    // ===== METHODS =====

    // Migration helper for hardcoded colours: returns `literal` under the
    // built-in dark theme (the default look stays pixel-identical) and the
    // palette `token` under an installed theme. QML twin of the C++
    // Logos::themeColor(token, fallback). Prefer plain Theme.palette.<token>
    // in new code.
    function tokenOr(token, literal) {
        return currentTheme === "dark" ? literal : palette[token]
    }

    function switchTheme() {
        // Cycle through available themes
        var themes = Object.keys(availableThemes)
        var currentIndex = themes.indexOf(currentTheme)
        var nextIndex = (currentIndex + 1) % themes.length
        setTheme(themes[nextIndex])
    }
    
    function setTheme(themeName) {
        if (!availableThemes[themeName]) {
            console.warn("Invalid theme:", themeName, ". Available themes:", Object.keys(availableThemes))
            return
        }
        settings.theme = themeName
        ThemeRegistry.current = themeName
        console.log("Theme set to:", themeName)
    }
    
    function setDark() {
        setTheme("dark")
    }
    
    // Helper to check if a theme is available
    function isThemeAvailable(themeName) {
        return availableThemes.hasOwnProperty(themeName)
    }
}
