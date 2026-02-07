# aporie.forms.ps1 per Dot-Sourcing laden
. ..\aporie.forms.ps1
# =======================================================

# Beispiel: Einfache Form mit einem Button
$form = createForm -Title "Test Form" -Width 300 -Height 200
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