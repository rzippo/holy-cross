# Reads a path from a txt file, and sends it to the game.
# The file must have a line for each step, with the direction in lower case
param(
    [Parameter(mandatory = $true)][string]$path
);

$tunic = "Secret Legend";

# scan codes
$left = 0x14b;
$up = 0x148;
$right = 0x14d;
$down = 0x150;

$directions = Get-Content $path;

$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate($tunic);

Start-Sleep 3
[console]::beep(500,300)

foreach($direction in $directions)
{
    $c = $direction[0];
    Write-Host $c -NoNewline;

    switch ($c) {
        'u' { ./Send-Key-Scan -KeyCode $up }
        'd' { ./Send-Key-Scan -KeyCode $down }
        'l' { ./Send-Key-Scan -KeyCode $left }
        'r' { ./Send-Key-Scan -KeyCode $right }
        
        Default {}
    }
    Start-Sleep 0.3;
}

[console]::beep(500,300)

Write-Host " ";
