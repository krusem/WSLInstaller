Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$ConsolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($ConsolePtr, 0)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

$URLs = "https://aka.ms/wsl-ubuntu-1804" ,"https://aka.ms/wsl-ubuntu-1604" ,"https://aka.ms/wsl-debian-gnulinux" ,"https://aka.ms/wsl-kali-linux" ,"https://aka.ms/wsl-opensuse-42"

$Installer                       = New-Object system.Windows.Forms.Form
$Installer.ClientSize            = '315,82'
$Installer.text                  = "WSL Installer"
$Installer.TopMost               = $false

$DistroSelect                    = New-Object system.Windows.Forms.ComboBox
$DistroSelect.text               = "Distributions"
$DistroSelect.width              = 187
$DistroSelect.height             = 20
@('Ubuntu 18.04','Ubuntu 16.04','Debian','Kali','OpenSuse') | ForEach-Object {[void] $DistroSelect.Items.Add($_)}
$DistroSelect.location           = New-Object System.Drawing.Point(15,40)
$DistroSelect.Font               = 'Microsoft Sans Serif,10'
$DistroSelect.SelectedIndex      = 0

$Label                           = New-Object system.Windows.Forms.Label
$Label.text                      = "Select version of Linux to install"
$Label.AutoSize                  = $true
$Label.width                     = 25
$Label.height                    = 10
$Label.location                  = New-Object System.Drawing.Point(15,15)
$Label.Font                      = 'Microsoft Sans Serif,10'

$GoButton                        = New-Object system.Windows.Forms.Button
$GoButton.text                   = "Go!"
$GoButton.width                  = 80
$GoButton.height                 = 45
$GoButton.location               = New-Object System.Drawing.Point(216,14)
$GoButton.Font                   = 'Microsoft Sans Serif,10'

$Installer.controls.AddRange(@($DistroSelect,$Label,$GoButton))

$GoButton.Add_Click({ OnGo })

function OnGo {
    try {
        $FileName = "$(Split-Path $URLs[$DistroSelect.SelectedIndex] -Leaf).appx"
        Invoke-WebRequest -Uri $URLs[$DistroSelect.SelectedIndex] -OutFile $FileName -UseBasicParsing
        Add-AppxPackage -Path $FileName
    }
    catch {
        [System.Windows.MessageBox]::Show('Error downloading or installing package', 'Error', 'OK', 'Error')
    }
}

Start-Process "wsl" -ArgumentList "--version" -WindowStyle Hidden
if(!$?) {
    $answer = [System.Windows.MessageBox]::Show('WSL does not appear to be installed.`nShould I install?', 'Question', 'YesNo', 'Question')
    if($answer -eq "Yes") {
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        }
        catch {
            [System.Windows.MessageBox]::Show('Error enabling WSL, administrator privilage is necessary', 'Error', 'OK', 'Error')
            exit(1)
        }
    } else {
        exit(0)
    }
} 

[void]$Installer.ShowDialog()
