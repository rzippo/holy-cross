# Records a path into a file from user input, so that it can then played back to the game
param(
    [Parameter(mandatory = $true)][string]$path
);

if(Test-Path $path)
{
    Write-Host "File already exists."
    exit;
}

Write-Host "Input path with arrow keys, press Q when done."
while($true) 
{
    $cki = [Console]::ReadKey($false);
    if($cki.Key -eq [ConsoleKey]::Q)
    {
        Write-Host "Done."
        exit;
    }

    if($cki.Key -eq [ConsoleKey]::RightArrow)
    {
        Write-Host "right";
        "right" >> $path;
        continue;
    }

    if($cki.Key -eq [ConsoleKey]::LeftArrow)
    {
        Write-Host "left";
        "left" >> $path;
        continue;
    }

    if($cki.Key -eq [ConsoleKey]::UpArrow)
    {
        Write-Host "up";
        "up" >> $path;
        continue;
    }

    if($cki.Key -eq [ConsoleKey]::DownArrow)
    {
        Write-Host "down";
        "down" >> $path;
        continue;
    }
}