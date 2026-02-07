# aporie.forms.ps1

# Assemblys laden
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
[System.Windows.Forms.Application]::EnableVisualStyles()

# Farben
$script:AccentColor = "#c0393b"
$script:DarkColor   = "#2d3436"
$script:LightColor  = "#f0f0f0"
$script:WhiteColor  = "#eeeeee"

# global-Variablen
$global:LabelToolTip  = New-Object System.Windows.Forms.ToolTip # Tooltip für Labels

# ═════ BASICS ═════════════════════════════════════════════════════════════════
function Merge-Config {
    param (
        [hashtable]$Defaults,
        [hashtable]$Config
    )

    if ($Config) {
        foreach ($key in $Config.Keys) {

            # NULL-Werte nicht übernehmen
            if ($null -ne $Config[$key] -and $Config[$key] -ne '') {
                $Defaults[$key] = $Config[$key]
            }
        }
    }

    return $Defaults
}
function colorTranslator {
        param (
            [string]$Color
        )
        try {
            return [System.Drawing.ColorTranslator]::FromHtml($Color) 
        } catch {
            Write-Warning "Ungültige Farbe: '$Color'. Verwende Standard: $script:AccentColor"
            return [System.Drawing.ColorTranslator]::FromHtml($script:AccentColor)
        }
}

# create-Bestandteile
function createFont {
    param (
        [string]$FontFamily = "Segoe UI",
        [int]$FontSize      = 9,
        [string]$FontStyle  = "Regular" # Regular, Bold, Italic, Underline, Strikeout
    )

    # FontStyle in Flags umwandeln
    $FontStyleFlags = 0
    $FontStyle.Split(',') | ForEach-Object {
        $validStyles    = @('Regular', 'Bold', 'Italic', 'Underline', 'Strikeout') # Gültige Stile
        $style          = $_.Trim() # Leerzeichen entfernen
        if ($validStyles -contains $style){
            $styleEnum      = [System.Drawing.FontStyle]::$style # Enum-Wert abrufen (Bold = 1, Italic = 2, Underline = 4, Strikeout = 8)
            $FontStyleFlags = $FontStyleFlags -bor [int]$styleEnum
        }
    }

    # FontFamily Fallback
    try {
        return New-Object System.Drawing.Font($FontFamily, $FontSize, [System.Drawing.FontStyle]$FontStyleFlags)
    } catch {
        try {
            return New-Object System.Drawing.Font("Consolas", $FontSize, [System.Drawing.FontStyle]$FontStyleFlags)
        } catch {
            return New-Object System.Drawing.Font("Microsoft Sans Serif", $FontSize, [System.Drawing.FontStyle]$FontStyleFlags)
        }
    }
}
function createLabelToolTip {
    return New-Object System.Windows.Forms.ToolTip    
}
function createLocation {
    param (
        [string]$Location   = '0,0',
        [int]$Padding       = 0,
        [int]$Left          = 0,
        [int]$Top           = 0
    )
    $coords = $Location -split ','
    $Left   += [int]$coords[0] + $Padding
    $Top    += [int]$coords[1] + $Padding

    return New-Object System.Drawing.Point($Left, $Top)
}
function createPadding {
    param (
        [int]$AllSides = 0,
        [int]$Left     = 0,
        [int]$Top      = 0,
        [int]$Right    = 0,
        [int]$Bottom   = 0
    )

    if ($AllSides -gt 0) {
        return New-Object System.Windows.Forms.Padding($AllSides)
    } else {
        return New-Object System.Windows.Forms.Padding($Left, $Top, $Right, $Bottom)
    }
}

# ═════ ELEMENTS ═══════════════════════════════════════════════════════════════
# create-Funktionen
function createButton {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Width  = 250,                         # Breite
        [int]$Height = 25,                          # Höhe

        # Position
        [string]$Location   = '0,0',                # Position im Format "x,y"
        [int]$Left          = 0,                    # Linker Abstand
        [int]$Top           = 0,                    # Oberer Abstand
        [int]$Padding       = 0,                    # Innenabstand
        

        # Text und Schrift
        [string]$Text       = 'Button',             # Button-Text
        [int]$FontSize      = 9,                    # Schriftgröße
        [string]$FontFamily = $DefaultFont,         # Schriftart
        [string]$FontStyle  = 'Regular',            # Schriftstil (Regular, Bold, Italic)
        [string]$ForeColor  = $AccentColor,         # Schriftfarbe (HTML oder Name)

        # Darstellung
        [string]$BackColor  = $DarkColor,           # Hintergrundfarbe (HTML oder Name)
        [string]$FlatStyle  = 'Flat',               # Stil (Flat, Standard, Popup, System)
        [string]$Anchor     = 'Top,Right,Left',     # Anker (Top, Left, Right, Bottom)
        [string]$Dock       = 'None',               # Andockposition (None, Top, Bottom, Left, Right, Fill)
        [string]$TextAlign  = 'MiddleCenter',       # Textausrichtung (TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight)
        [string]$ImageAlign = 'MiddleCenter',       # Bildausrichtung
        
        # Verhalten
        [string]$Cursor     = 'Default',            # Mauszeiger (Default, Hand, AppStarting, Cross, Help, IBeam, No, WaitCursor)
        [bool]$Enabled      = $true,                # Button aktiviert
        [bool]$Visible      = $true,                # Button sichtbar
        [bool]$AutoSize     = $false,               # Automatische Größe
        [bool]$UseVisualStyleBackColor = $false,    # Verwendet Windows-Themes
        [bool]$TabStop      = $true,                # Tab-Navigation aktiviert
        [int]$TabIndex      = -1,                   # Tab-Reihenfolge (-1 = automatisch)
        
        # Flat-Button-Einstellungen
        [int]$FlatAppearanceBorderSize = 1,         # Rahmengröße bei FlatStyle
        [string]$FlatAppearanceBorderColor = $AccentColor, # Rahmenfarbe
        [string]$FlatAppearanceMouseDownBackColor = $AccentColor, # Hintergrund beim Klicken
        [string]$FlatAppearanceMouseOverBackColor = $AccentColor, # Hintergrund beim Hovern
        
        # Bild/Icon
        [string]$Image      = '',                   # Bildpfad oder Base64-String
        [string]$ImageKey   = '',                   # Schlüssel für ImageList
        [object]$ImageList  = $null,                # ImageList-Objekt
        
        # Dialog-Rückgabewert
        [string]$DialogResult = 'None'              # DialogResult (None, OK, Cancel, Abort, Retry, Ignore, Yes, No)
    )

    $defaults = @{
        Width      = $Width
        Height     = $Height
        Location   = $Location
        Left       = $Left
        Top        = $Top
        Padding    = $Padding
        Text       = $Text
        FontSize   = $FontSize
        FontFamily = $FontFamily
        FontStyle  = $FontStyle
        ForeColor  = $ForeColor
        BackColor  = $BackColor
        FlatStyle  = $FlatStyle
        Anchor     = $Anchor
        Dock       = $Dock
        TextAlign  = $TextAlign
        ImageAlign = $ImageAlign
        Cursor     = $Cursor
        Enabled    = $Enabled
        Visible    = $Visible
        AutoSize   = $AutoSize
        UseVisualStyleBackColor = $UseVisualStyleBackColor
        TabStop    = $TabStop
        TabIndex   = $TabIndex

        FlatAppearanceBorderSize         = $FlatAppearanceBorderSize
        FlatAppearanceBorderColor        = $FlatAppearanceBorderColor
        FlatAppearanceMouseDownBackColor = $FlatAppearanceMouseDownBackColor
        FlatAppearanceMouseOverBackColor = $FlatAppearanceMouseOverBackColor

        Image      = $Image
        ImageKey   = $ImageKey
        ImageList  = $ImageList
        DialogResult = $DialogResult
    }
    $p = Merge-Config -Defaults $defaults -Config $config
    
    # === Button-Objekt erzeugen ===
    $button = New-Object System.Windows.Forms.Button


    $button.Location    = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $button.Font        = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize -FontStyle $p.FontStyle
    $button.Text        = $p.Text
    $button.Width       = $p.Width
    $button.Height      = $p.Height
    $button.Anchor      = $p.Anchor
    $button.Dock        = $p.Dock
    $button.FlatStyle   = $p.FlatStyle
    $button.TextAlign   = [System.Drawing.ContentAlignment]::$($p.TextAlign)
    $button.ImageAlign  = [System.Drawing.ContentAlignment]::$($p.ImageAlign)
    $button.ForeColor   = colorTranslator -Color $p.ForeColor
    $button.BackColor   = colorTranslator -Color $p.BackColor
    $button.Cursor      = [System.Windows.Forms.Cursors]::$p.Cursor
    $button.Enabled     = $p.Enabled
    $button.Visible     = $p.Visible
    $button.AutoSize    = $p.AutoSize
    $button.UseVisualStyleBackColor = $p.UseVisualStyleBackColor
    $button.TabStop     = $p.TabStop
    
    # Tab-Index setzen (nur wenn nicht -1)
    if ($p.TabIndex -ge 0) { $button.TabIndex = $p.TabIndex }
    
    # Flat-Appearance-Einstellungen (nur bei FlatStyle = Flat)
    if ($p.FlatStyle -eq 'Flat') {
        $button.FlatAppearance.BorderSize         = $p.FlatAppearanceBorderSize
        $button.FlatAppearance.BorderColor        = colorTranslator -Color $p.FlatAppearanceBorderColor
        $button.FlatAppearance.MouseDownBackColor = colorTranslator -Color $p.FlatAppearanceMouseDownBackColor
        $button.FlatAppearance.MouseOverBackColor = colorTranslator -Color $p.FlatAppearanceMouseOverBackColor
    }
    
    # Bild/Icon setzen
    if ($Image) {
        if (Test-Path $Image) {
            $button.Image = [System.Drawing.Image]::FromFile($Image)
        } else {
            # Versuche Base64-Dekodierung
            try {
                $bytes        = [Convert]::FromBase64String($Image)
                $stream       = New-Object System.IO.MemoryStream(,$bytes)
                $button.Image = [System.Drawing.Image]::FromStream($stream)
            } catch {
                Write-Warning "Bild konnte nicht geladen werden: $Image"
            }
        }
    }
    
    # ImageList verwenden
    if ($ImageList -and $ImageKey) {
        $button.ImageList = $ImageList
        $button.ImageKey  = $ImageKey
    }
    
    # DialogResult setzen
    if ($DialogResult -ne 'None') {
        $button.DialogResult = [System.Windows.Forms.DialogResult]::$DialogResult
    }

    return $button

}
function createCheckBox {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Width = 100,                      # Breite des CheckBox
        [int]$Height = 25,                      # Höhe des CheckBox

        # Position
        [string]$Location = '0,0',                      # Position des CheckBox (x,y)
        [int]$Left          = 0,
        [int]$Top           = 0,
        [int]$Padding       = 0,

        # Text & Schrift
        [string]$Text = 'CheckBox',            # Text des CheckBox
        [string]$FontFamily = $DefaultFont,     # Schriftart
        [int]$FontSize = 11,                    # Schriftgröße
        [string]$FlatStyle = 'Standard',     # Stil des CheckBox (Flat, Standard)

        # Darstellung
        [string]$BackColor = $DarkColor,        # Hintergrundfarbe
        [string]$ForeColor = $WhiteColor,       # Schriftfarbe
        [string]$BorderColor = $AccentColor,    # Rahmenfarbe 

        # Verhalten
        [string]$Anchor = 'Top,Right,Left',     # Ankerposition
        [bool]$ThreeState = $false              # Drei-Zustände-Modus (Unchecked, Checked, Indeterminate)
    )

    $defaults = @{
        Width       = $Width
        Height      = $Height
        Location    = $Location
        Left        = $Left
        Top         = $Top
        Padding     = $Padding
        Text        = $Text
        FontFamily  = $FontFamily
        FontSize    = $FontSize
        FlatStyle   = $FlatStyle
        BackColor   = $BackColor
        ForeColor   = $ForeColor
        BorderColor = $BorderColor
        Anchor      = $Anchor
        ThreeState  = $ThreeState
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $checkBox = New-Object System.Windows.Forms.CheckBox
    $checkBox.Location     = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $checkBox.Height          = $p.Height
    $checkBox.Width           = $p.Width
    $checkBox.Anchor          = $p.Anchor
    $checkBox.Font            = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize
    $checkBox.ForeColor       = colorTranslator -Color $p.ForeColor
    $checkBox.BackColor       = colorTranslator -Color $p.BackColor
    $checkBox.Text            = $p.Text
    $checkBox.ThreeState      = $p.ThreeState

    return $checkBox

}
function createCheckedListBox {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe & Position
        [int]$Width = 200,      # Breite des CheckedListBox
        [int]$Height = 150,     # Höhe des CheckedListBox

        [string]$Location = '0,0',      # Position des CheckedListBox (x,y)
        [int]$Left          = 0,
        [int]$Top           = 0,
        [int]$Padding       = 0,

        # Verhalten
        [bool]$CheckOnClick = $true,    # Aktiviert Checkbox direkt beim Klicken
        
        # Darstellung
        [string]$BackColor = $DarkColor,        # Hintergrundfarbe
        [string]$ForeColor = $WhiteColor,       # Schriftfarbe
        [string]$FontFamily = $DefaultFont,     # Schriftart
        [int]$FontSize = 11,                    # Schriftgröße
        [string]$BorderColor = $AccentColor,    # Rahmenfarbe 
        
        # Zusätzliche Eigenschaften
        [bool]$AutoScroll = $true,              # Ermöglicht vertikales Schrollen
        [string]$FlatStyle = 'Flat',            # Stil des Steuerelements (Flat, Standard)
        [string]$BorderStyle = 'None',          # Rahmenstil (None, FixedSingle, Fixed3D)
        [string]$Anchor = 'Top,Right,Left',     # Verankerung innerhalb des Containers
        [string]$SelectionMode = 'MultiSimple', # Auswahlmodus des Listbox (None, One, MultiSimple, MultiExtended)
        
        [bool]$MultiColumn = $false,    # Mehrere Spalten aktivieren
        [int]$ColumnWidth = 200,        # Breite der Spalten
        [int]$ItemHeight = 20           # Höhe der Listeneinträge
    )

    $defaults = @{
        Width         = $Width
        Height        = $Height
        Location      = $Location
        Left          = $Left
        Top           = $Top
        Padding       = $Padding
        CheckOnClick  = $CheckOnClick
        BackColor     = $BackColor
        ForeColor     = $ForeColor
        FontFamily    = $FontFamily
        FontSize      = $FontSize
        BorderColor   = $BorderColor
        AutoScroll    = $AutoScroll
        FlatStyle     = $FlatStyle
        BorderStyle   = $BorderStyle
        Anchor        = $Anchor
        SelectionMode = $SelectionMode
        MultiColumn   = $MultiColumn
        ColumnWidth   = $ColumnWidth
        ItemHeight    = $ItemHeight
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Location        = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $checkedListBox.Font            = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize
    $checkedListBox.FlatStyle       = $p.FlatStyle
    $checkedListBox.Height          = $p.Height
    $checkedListBox.Width           = $p.Width
    $checkedListBox.Anchor          = $p.Anchor
    $checkedListBox.AutoScroll      = $p.AutoScroll
    $checkedListBox.ForeColor       = colorTranslator -Color $p.ForeColor
    $checkedListBox.BackColor       = colorTranslator -Color $p.BackColor
    $checkedListBox.BorderStyle     = [System.Windows.Forms.BorderStyle]::$($p.BorderStyle)
    $checkedListBox.SelectionMode   = $p.SelectionMode
    $checkedListBox.CheckOnClick    = $p.CheckOnClick
    $checkedListBox.MultiColumn     = $p.MultiColumn
    $checkedListBox.ColumnWidth     = $p.ColumnWidth
    $checkedListBox.ItemHeight      = $p.ItemHeight
    $checkedListBox.DisplayMember   = 'Name'

    return $checkedListBox
}
function createDropDownList {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Height = 25,      # Höhe der ComboBox
        [int]$Width = 200,      # Breite der ComboBox

        # Position
        [string]$Location   = '0,0',    # Position im Format (x,y)
        [int]$Left          = 0,        # Linker Abstand
        [int]$Top           = 0,        # Oberer Abstand
        [int]$Padding       = 0,        # Innenabstand
        
        # Schrift & Farben
        [int]$FontSize      = 11,               # Schriftgröße
        [string]$FontFamily = $DefaultFont,     # Schriftart
        [string]$FontStyle  = 'Regular',        # Schriftstil (Regular, Bold, Italic)
        [string]$ForeColor  = $DarkColor,       # Schriftfarbe
        [string]$BackColor  = $AccentColor,     # Hintergrundfarbe
        
        # Darstellung
        [string]$Anchor         = 'Top,Right,Left',     # Ankerposition
        [string]$DropDownStyle  = 'DropDownList',       # Dropdown-Stil (DropDown, DropDownList, Simple)
        [string]$FlatStyle      = 'Standard',           # Stil der ComboBox (Flat, Standard, Popup, System)
        [int]$DropDownHeight    = 106,                  # Maximale Höhe der Dropdown-Liste
        [int]$DropDownWidth     = 0,                    # Breite der Dropdown-Liste (0 = automatisch)
        [int]$MaxDropDownItems  = 8,                    # Maximale Anzahl sichtbarer Elemente
        
        # Verhalten
        [bool]$Sorted           = $false,               # Elemente alphabetisch sortieren
        [bool]$Enabled          = $true,                # ComboBox aktiviert
        [bool]$Visible          = $true,                # ComboBox sichtbar
        [int]$MaxLength         = 0,                    # Maximale Textlänge (0 = unbegrenzt)
        [bool]$IntegralHeight   = $true,                # Höhe anpassen, um vollständige Elemente anzuzeigen
        
        # Inhalt
        [string]$Text           = "",                   # Standardtext der ComboBox
        [int]$SelectedIndex     = -1,                   # Ausgewählter Index
        [string]$SelectedItem,                          # Ausgewähltes Element
        [string[]]$Items        = @(),                  # Elemente der ComboBox
        [string]$DisplayMember  = "",                   # Anzuzeigende Eigenschaft bei Objekten
        [string]$ValueMember    = ""                    # Wert-Eigenschaft bei Objekten
    )

    $defaults = @{
        Height            = $Height
        Width             = $Width
        Location          = $Location
        Left              = $Left
        Top               = $Top
        Padding           = $Padding
        FontSize          = $FontSize
        FontFamily        = $FontFamily
        FontStyle         = $FontStyle
        ForeColor         = $ForeColor
        BackColor         = $BackColor
        Anchor            = $Anchor
        DropDownStyle     = $DropDownStyle
        FlatStyle         = $FlatStyle
        DropDownHeight    = $DropDownHeight
        DropDownWidth     = $DropDownWidth
        MaxDropDownItems  = $MaxDropDownItems
        Sorted            = $Sorted
        Enabled           = $Enabled
        Visible           = $Visible
        MaxLength         = $MaxLength
        IntegralHeight    = $IntegralHeight
        Text              = $Text
        SelectedIndex     = $SelectedIndex
        SelectedItem      = $SelectedItem
        Items             = $Items
        DisplayMember     = $DisplayMember
        ValueMember       = $ValueMember
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $dropDownList = New-Object System.Windows.Forms.ComboBox
    $dropDownList.Location          = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $dropDownList.Font              = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize -FontStyle $p.FontStyle

    $dropDownList.Height            = $p.Height
    $dropDownList.Width             = $p.Width
    $dropDownList.Anchor            = $p.Anchor
    $dropDownList.DropDownStyle     = $p.DropDownStyle
    $dropDownList.FlatStyle         = $p.FlatStyle
    $dropDownList.DropDownHeight    = $p.DropDownHeight
    $dropDownList.MaxDropDownItems  = $p.MaxDropDownItems
    $dropDownList.Sorted            = $p.Sorted
    $dropDownList.Enabled           = $p.Enabled
    $dropDownList.Visible           = $p.Visible
    $dropDownList.MaxLength         = $p.MaxLength
    $dropDownList.IntegralHeight    = $p.IntegralHeight

    # Schrift & Farben setzen
    $dropDownList.ForeColor = colorTranslator -Color $p.ForeColor
    $dropDownList.BackColor = colorTranslator -Color $p.BackColor

    # DropDownWidth setzen (0 = automatisch, sonst benutzerdefiniert)
    if ($p.DropDownWidth -gt 0) { $dropDownList.DropDownWidth = $p.DropDownWidth }

    # DisplayMember und ValueMember für Objekte
    if ($p.DisplayMember) { $dropDownList.DisplayMember = $p.DisplayMember }
    if ($p.ValueMember)   { $dropDownList.ValueMember = $p.ValueMember }

    # Items hinzufügen
    if ($p.Items.Count -gt 0) { $dropDownList.Items.AddRange($p.Items) }

    # Standardtext setzen
    $dropDownList.Text = $p.Text

    # Ausgewählten Index setzen
    if ($p.SelectedIndex -ge 0 -and $p.SelectedIndex -lt $dropDownList.Items.Count) {
        $dropDownList.SelectedIndex = $p.SelectedIndex
    }

    # Ausgewähltes Element setzen (überschreibt SelectedIndex)
    if ($p.SelectedItem -and $p.Items -contains $p.SelectedItem) {
        $dropDownList.SelectedIndex = $dropDownList.Items.IndexOf($p.SelectedItem)
    }
    
    return $dropDownList
}
function createForm {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,
        [object]$controls,

        # Größe & Position
        [int]$Width = 400,                            # Breite des Fensters
        [int]$Height = 300,                           # Höhe des Fensters
        [string]$StartPosition = 'CenterScreen',      # Startposition (CenterScreen, Manual, WindowsDefaultLocation)
        
        # Darstellung
        [string]$Text = "Fenstertitel",               # Fenstertitel
        [string]$BackColor = $AccentColor,            # Hintergrundfarbe (HTML oder Name)
        [string]$FormBorderStyle = 'FixedSingle',     # Rahmenstil (None, FixedSingle, Fixed3D, Sizable, etc.)
        
        # Fensterverhalten
        [bool]$TopMost = $true,                       # Immer im Vordergrund
        [bool]$ShowIcon = $false,                     # Icon anzeigen
        [string]$Base64,                              # Base64-Icon
        [bool]$MinimizeBox = $false,                  # Minimieren-Schaltfläche
        [bool]$MaximizeBox = $false                   # Maximieren-Schaltfläche
    )

    $defaults = @{
        Width           = $Width
        Height          = $Height
        StartPosition   = $StartPosition
        Text            = $Text
        BackColor       = $BackColor
        FormBorderStyle = $FormBorderStyle
        TopMost         = $TopMost
        ShowIcon        = $ShowIcon
        Base64          = $Base64
        MinimizeBox     = $MinimizeBox
        MaximizeBox     = $MaximizeBox
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    # Formular erstellen und Eigenschaften setzen
    $form = New-Object System.Windows.Forms.Form
    $form.ClientSize        = New-Object System.Drawing.Size($p.Width, $p.Height)
    $form.StartPosition     = $p.StartPosition
    $form.FormBorderStyle   = $p.FormBorderStyle
    $form.MinimizeBox       = $p.MinimizeBox
    $form.MaximizeBox       = $p.MaximizeBox
    $form.ShowIcon          = $p.ShowIcon
    $form.Text              = $p.Text
    $form.TopMost           = $p.TopMost
    $form.BackColor         = colorTranslator -Color $p.BackColor

    # Base64-Icon
    if ($p.Base64){
        $form.ShowIcon = $true
        $Bytes = [Convert]::FromBase64String($p.Base64)
        $Stream = New-Object System.IO.MemoryStream(,$Bytes)
        $Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::FromStream($Stream)).GetHicon())
        $form.Icon = $Icon
    }
    # Controls hinzufügen
    if ($controls) {
        if ($controls -is [hashtable]) {
            foreach ($control in $controls.Values) {
                $form.Controls.Add($control)
            }
        } elseif ($controls -is [array]) {
            $form.Controls.AddRange($controls)
        } else {
            $form.Controls.Add($controls)
        }
    }

    return $form
}
function createLabel {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,
        [object]$Add_DoubleClickEvent,

        # Größe
        [int]$Width  = 100, # Breite des Labels
        [int]$Height = 30,  # Höhe des Labels

        # Position
        [string]$Location   = "0,0", # Position des Labels (x,y)
        [int]$Left          = 0,     # Linker Rand
        [int]$Top           = 0,     # Oberer Rand
        [int]$Padding       = 0,     # Innenabstand des Labels (Padding)

        # Text & Schrift
        [string]$Text       = 'Label',          # Text des Labels
        [string]$FontFamily = $DefaultFont,     # Schriftart des Labels
        [int]$FontSize      = 12,               # Schriftgröße des Labels
        [string]$FontStyle  = 'Regular',        # Schriftstil des Labels (Regular, Bold, Italic)
        [string]$FlatStyle  = 'Standard',       # Stil des Labels (Flat, Standard)

        # Darstellung
        [bool]$AutoSize     = $false,           # Automatische Größe des Labels
        [string]$Dock       = "None",           # Andockposition des Labels (None, Top, Bottom, Left, Right, Fill)
        [string]$Anchor     = 'Top,Right,Left', # Ankerposition des Labels (Top, Left, Right, Bottom)
        [string]$ForeColor  = $WhiteColor,      # Schriftfarbe des Labels
        [string]$BackColor  = $DarkColor,       # Hintergrundfarbe des Labels
        [string]$TextAlign  = 'MiddleCenter',   # Textausrichtung im Label (TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight)

        # Verhalten
        [switch]$Hand           = $false,       # Hand-Cursor aktivieren
        [bool]$Visible          = $true,        # Sichtbarkeit des Labels
        [string]$Description    = ''            # Beschreibung des Labels
    )

    $defaults = @{
        Width       = $Width
        Height      = $Height
        Location    = $Location
        Left        = $Left
        Top         = $Top
        Padding     = $Padding
        Text        = $Text
        FontFamily  = $FontFamily
        FontSize    = $FontSize
        FontStyle   = $FontStyle
        FlatStyle   = $FlatStyle
        AutoSize    = $AutoSize
        Dock        = $Dock
        Anchor      = $Anchor
        ForeColor   = $ForeColor
        BackColor   = $BackColor
        TextAlign   = $TextAlign
        Hand        = $Hand
        Visible     = $Visible
        Description = $Description
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $label = New-Object System.Windows.Forms.Label
    $label.Location     = createLocation -Location $p.Location -Left $p.Left -Top $p.Top
    $label.Font         = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize -FontStyle $p.FontStyle
    $label.Padding      = createPadding -AllSides $p.Padding

    $label.Text         = $p.Text
    $label.AutoSize     = $p.AutoSize
    $label.Width        = $p.Width
    $label.Height       = $p.Height
    $label.Anchor       = $p.Anchor
    $label.ForeColor    = colorTranslator -Color $p.ForeColor
    $label.BackColor    = colorTranslator -Color $p.BackColor
    $label.TextAlign    = [System.Drawing.ContentAlignment]::$($p.TextAlign)
    $label.Visible      = $p.Visible
    $label.Dock         = $p.Dock

    # Tooltip setzen, falls vorhanden
    if ($p.Description) { $global:LabelToolTip.SetToolTip($label, $p.Description) }

    # Cursor ändern, falls Hand gewünscht
    if ($p.Hand) { $label.Cursor = [System.Windows.Forms.Cursors]::Hand }

    # Doppelklick-Ereignis hinzufügen, falls angegeben
    if ($Add_DoubleClickEvent) {
        $label.Add_DoubleClick($Add_DoubleClickEvent)
    }

    return $label
}
function createListBox {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Height = 150,     # Höhe der ListBox
        [int]$Width = 200,      # Breite der ListBox

        # Position
        [string]$Location = '0,0',  # Position im Format (x,y)
        [int]$Left          = 0,                # Linker Rand
        [int]$Top           = 0,                # Oberer Rand
        [int]$Padding       = 0,                # Innenabstand

        # Schrift & Farben
        [int]$FontSize = 11,                # Schriftgröße
        [string]$FontFamily = $DefaultFont,   # Schriftart
        [string]$ForeColor = $WhiteColor,   # Textfarbe
        [string]$BackColor = $DarkColor,    # Hintergrundfarbe

        # Verhalten & Darstellung
        [string]$Anchor = 'Top,Right,Left',     # Ankerposition
        [string]$SelectionMode = 'MultiSimple', # Auswahlmodus: None, One, MultiSimple, MultiExtended
        [bool]$AutoScroll = $true               # horizontaler Scrollbalken bei Überlänge
    )

    $defaults = @{
        Height        = $Height
        Width         = $Width
        Location      = $Location
        Left          = $Left
        Top           = $Top
        Padding       = $Padding
        FontSize      = $FontSize
        FontFamily    = $FontFamily
        ForeColor     = $ForeColor
        BackColor     = $BackColor
        Anchor        = $Anchor
        SelectionMode = $SelectionMode
        AutoScroll    = $AutoScroll
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location      = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $listBox.Font           = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize
    $listBox.Height         = $p.Height
    $listBox.Width          = $p.Width
    $listBox.Anchor         = $p.Anchor

    # Schrift und Farben setzen
    $listBox.ForeColor      = colorTranslator -Color $p.ForeColor
    $listBox.BackColor      = colorTranslator -Color $p.BackColor

    # Darstellung & Verhalten
    $listBox.BorderStyle        = [System.Windows.Forms.BorderStyle]::None
    $listBox.SelectionMode      = $p.SelectionMode
    $listBox.HorizontalScrollbar = $p.AutoScroll

    return $listBox
}
function createPanel {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,
        [object]$controls,

        # Größe
        [int]$Height = 100,     # Höhe des Panels
        [int]$Width = 200,      # Breite des Panels

        # Position
        [string]$Location = '0,0',      # Position des Panels (x,y)
        [int]$Padding = 0,  # Innenabstand des Panels
        [int]$Left = 0,
        [int]$Top = 0,

        # Darstellung
        [string]$BackColor      = $DarkColor,        # Hintergrundfarbe des Panels
        [string]$FlatStyle      = 'Flat',            # Stil des Panels (Flat, Standard)
        [string]$Anchor         = 'Top,Right,Left',  # Ankerposition des Panels (Top, Left, Right, Bottom)
        [string]$BorderStyle    = 'None',            # Rahmenstil des Panels (None, FixedSingle, Fixed3D)
        
        # Verhalten
        [bool]$AutoScroll = $false  # Automatisches Scrollen
    )

    $defaults = @{
        Height      = $Height
        Width       = $Width
        Location    = $Location
        Padding     = $Padding
        Left        = $Left
        Top         = $Top
        BackColor   = $BackColor
        FlatStyle   = $FlatStyle
        Anchor      = $Anchor
        BorderStyle = $BorderStyle
        AutoScroll  = $AutoScroll
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top

    $panel.Height       = $p.Height
    $panel.Width        = $p.Width
    $panel.Anchor       = $p.Anchor
    $panel.BackColor    = colorTranslator -Color $p.BackColor
    $panel.AutoScroll   = $p.AutoScroll
    $panel.BorderStyle  = [System.Windows.Forms.BorderStyle]::$($p.BorderStyle)

    if ($controls) {
        if ($controls -is [hashtable]) {
            foreach ($control in $controls.Values) {
                $panel.Controls.Add($control)
            }
        } elseif ($controls -is [array]) {
            $panel.Controls.AddRange($controls)
        } else {
            $panel.Controls.Add($controls)
        }
    }

    return $panel
}
function createRichTextBox {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Width = 300,                        # Breite der RichTextBox
        [int]$Height = 100,                       # Höhe der RichTextBox

        # Position
        [string]$Location = '0,0',              # Position (x,y)
        [int]$Left          = 0,
        [int]$Top           = 0,
        [int]$Padding       = 0,

        # Text & Schrift
        [string]$Text = '',                       # Standardtext
        [string]$FontFamily = $DefaultFont,       # Schriftart
        [int]$FontSize = 10,                      # Schriftgröße
        [string]$FontStyle = 'Regular',           # Schriftstil

        # Darstellung
        [string]$ForeColor = $WhiteColor,         # Schriftfarbe
        [string]$BackColor = $DarkColor,          # Hintergrundfarbe
        [bool]$ReadOnly = $true,                  # Nur-Lesen-Modus
        [bool]$Border = $false,                   # Rahmen anzeigen oder nicht
        [string]$BorderStyle = 'None',            # Rahmenstil (None, FixedSingle, Fixed3D)

        # Verhalten
        [string]$Anchor = 'Top,Right,Left',       # Ankerposition
        [bool]$Visible = $true,                   # Sichtbarkeit
        [string]$Description = ''                 # Tooltip/Beschreibung
    )

    $defaults = @{
        Width       = $Width
        Height      = $Height
        Location    = $Location
        Left        = $Left
        Top         = $Top
        Padding     = $Padding
        Text        = $Text
        FontFamily  = $FontFamily
        FontSize    = $FontSize
        FontStyle   = $FontStyle
        ForeColor   = $ForeColor
        BackColor   = $BackColor
        ReadOnly    = $ReadOnly
        Border      = $Border
        BorderStyle = $BorderStyle
        Anchor      = $Anchor
        Visible     = $Visible
        Description = $Description
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $rtb = New-Object System.Windows.Forms.RichTextBox
    $rtb.Location      = createLocation -Location $p.Location -Left $p.Left -Top $p.Top -Padding $p.Padding
    $rtb.Font          = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize -FontStyle $p.FontStyle
    $rtb.Multiline     = $true
    $rtb.ScrollBars    = 'Vertical'
    $rtb.WordWrap      = $true
    $rtb.ReadOnly      = $p.ReadOnly
    $rtb.Text          = $p.Text
    $rtb.Width         = $p.Width
    $rtb.Height        = $p.Height
    $rtb.Anchor        = $p.Anchor
    $rtb.ForeColor     = colorTranslator -Color $p.ForeColor
    $rtb.BackColor     = colorTranslator -Color $p.BackColor
    $rtb.Visible       = $p.Visible

    if (-not $p.Border) {
        $rtb.BorderStyle = [System.Windows.Forms.BorderStyle]::$($p.BorderStyle)
    }

    if ($p.Description) {
        $global:LabelToolTip.SetToolTip($rtb, $p.Description)
    }

    return $rtb
}
function createRadioButton {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Größe
        [int]$Width = 100,                      # Breite des RadioButton
        [int]$Height = 25,                      # Höhe des RadioButton

        # Position
        [string]$Location = '0,0',              # Position des RadioButton (x,y)
        [int]$Left          = 0,
        [int]$Top           = 0,
        [int]$Padding       = 0,

        # Text & Schrift
        [string]$Text = 'RadioButton',         # Text des RadioButton
        [string]$FontFamily = $DefaultFont,     # Schriftart
        [int]$FontSize = 11,                    # Schriftgröße
        [string]$FlatStyle = 'Standard',     # Stil des RadioButton (Flat, Standard)

        # Darstellung
        [string]$BackColor = $DarkColor,        # Hintergrundfarbe
        [string]$ForeColor = $WhiteColor,       # Schriftfarbe

        # Verhalten
        [string]$Anchor = 'Top,Right,Left'      # Ankerposition
    )

    $defaults = @{
        Width      = $Width
        Height     = $Height
        Location   = $Location
        Left       = $Left
        Top        = $Top
        Padding    = $Padding
        Text       = $Text
        FontFamily = $FontFamily
        FontSize   = $FontSize
        FlatStyle  = $FlatStyle
        BackColor  = $BackColor
        ForeColor  = $ForeColor
        Anchor     = $Anchor
    }
    $p = Merge-Config -Defaults $defaults -Config $config

    $radioButton = New-Object System.Windows.Forms.RadioButton
    $radioButton.Location     = createLocation -Location $p.Location -Padding $p.Padding -Left $p.Left -Top $p.Top
    $radioButton.Font            = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize
    $radioButton.Height          = $p.Height
    $radioButton.Width           = $p.Width
    $radioButton.Anchor          = $p.Anchor
    
    $radioButton.ForeColor       = colorTranslator -Color $p.ForeColor
    $radioButton.BackColor       = colorTranslator -Color $p.BackColor
    $radioButton.Text            = $p.Text

    return $radioButton
}
function createTextBox {
    param (
        # Hashtable-Konfiguration (optional)
        [hashtable]$config,

        # Darstellung
        [string]$Text        = 'TextBox',     # Standardtext
        [string]$BorderStyle = 'FixedSingle', # Rahmenstil (None, FixedSingle, Fixed3D)

        # Größe & Position
        [int]$Height = 25,                  # Höhe der TextBox
        [int]$Width = 200,                  # Breite des TextBox
        [string]$Anchor = 'Top,Right,Left', # Ankerposition (z.B. Top, Left, Right, Bottom)
        
        [string]$Location = '0,0',          # Position des TextBox (x,y)
        [int]$Left          = 0,
        [int]$Top           = 0,
        [int]$Padding       = 0,
        
        # Schrift & Farben
        [string]$FontFamily = $DefaultFont, # Schriftart
        [int]$FontSize = 9,                 # Schriftgröße
        [string]$ForeColor = $WhiteColor,   # Schriftfarbe
        [string]$BackColor = $DarkColor     # Hintergrundfarbe
    )

    $p = Merge-Config -Config $config -Defaults @{
            Text        = $Text
            BorderStyle = $BorderStyle
            Height      = $Height
            Width       = $Width
            Anchor      = $Anchor
            Location    = $Location
            Left        = $Left
            Top         = $Top
            Padding     = $Padding
            FontFamily  = $FontFamily
            FontSize    = $FontSize
            ForeColor   = $ForeColor
            BackColor   = $BackColor
    }

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location       = createLocation -Location $p.Location -Left $p.Left -Top $p.Top
    $textBox.Padding        = createPadding -AllSides $p.Padding
    $textBox.Font           = createFont -FontFamily $p.FontFamily -FontSize $p.FontSize
    $textBox.Text           = $p.Text
    $textBox.Height         = $p.Height
    $textBox.Width          = $p.Width
    $textBox.Anchor         = $p.Anchor

    # Schrift & Farben anwenden
    $textBox.ForeColor  = colorTranslator -Color $p.ForeColor
    $textBox.BackColor  = colorTranslator -Color $p.BackColor

    # Rahmenstil festlegen
    $textBox.BorderStyle = [System.Windows.Forms.BorderStyle]::$($p.BorderStyle)

    return $textBox
}

# ══════ CHANGE ════════════════════════════════════════════════════════════════
# change-Funktion
function changeCursor {
    param (
        [System.Windows.Forms.Control]$Object,
        [string]$NewCursor
    )
    $Object.Cursor = [System.Windows.Forms.Cursors]::$NewCursor
}
function changeFont {
    param (
        [System.Windows.Forms.Control]$Object,
        [string]$FontFamily = $Object.Font.FontFamily.Name,
        [int]$FontSize = [int]$Object.Font.Size,
        [string]$FontStyle = $Object.Font.Style.ToString()
    )

    return createFont -FontFamily $FontFamily -FontSize $FontSize -FontStyle $FontStyle
}