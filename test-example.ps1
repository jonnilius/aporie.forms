# aporie.forms.ps1 per Dot-Sourcing laden
$formsPath = Join-Path $PSScriptRoot 'aporie.forms.ps1'
if (Test-Path $formsPath) { . $formsPath } 
else { throw "Die Datei 'aporie.forms.ps1' konnte nicht gefunden werden." }
# =======================================================

# Beispiel: Einfache Form mit einem Button
$form = createForm @{
    Title = "Test Form"
    Width = 300
    Height = 200
}
$button = createButton @{
        Text = "Klick mich!"
        Width = 100
        Height = 30
        Location = "100,70"
        OnClick = {
            [System.Windows.MessageBox]::Show("Button wurde geklickt!")
        }
}
$form.Controls.Add($button)
$form.ShowDialog() | Out-Null