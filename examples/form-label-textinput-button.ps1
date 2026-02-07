. ..\aporie.forms.ps1
# =======================================================

# Beispiel: Einfache Form mit einem Label, TextBox und Button
$form = createForm -Title "Test Form" -Width 300 -Height 200
$label = createLabel @{
        Text = "Gib deinen Namen ein:"
        Location = "10,20"
        AutoSize = $true
}
$textBox = createTextBox @{
        Location = "10,50"
        Width = 200
}
$button = createButton @{
        Text = "Klick mich!"
        Width = 100
        Height = 30
        Location = "10,90"
        OnClick = {
            $name = $textBox.Text
            [System.Windows.MessageBox]::Show("Hallo, $name!")
        }
}
$form.Controls.Add($label)
$form.Controls.Add($textBox)
$form.Controls.Add($button)
$form.ShowDialog() | Out-Null