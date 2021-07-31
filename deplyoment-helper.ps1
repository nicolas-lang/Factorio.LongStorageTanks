Remove-Variable * -ErrorAction SilentlyContinue;
Remove-Module *; $error.Clear();
Clear-Host; $ErrorActionPreference = "Stop"
[string] $baseDirectory = (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent).TrimEnd("/").TrimEnd("\")
#-----------------------------------------------------------------------
add-type -AssemblyName System.Drawing
function Build-ImageInfo {
	param(
		 [string]$gfxFolder
		,[string]$modName
	)
	if ((Test-Path $gfxFolder) -eq $false) {
		return
	}
    Set-Location $gfxFolder
	$ImageInfo = @($('local myGlobal = require("__'+$modName+'__/lib/nco_data")'))
	$ImageInfo += "myGlobal.imageInfo = myGlobal.imageInfo or {}"
	Get-Childitem -Path $gfxFolder -Filter "*.png" -recurse |% {
		$png = New-Object System.Drawing.Bitmap $_.FullName
		$imagePath = $( $($_ | Resolve-Path -Relative) -replace [System.Text.RegularExpressions.Regex]::Escape(".\"),$("__" + $modName + "__/graphics/") -replace [System.Text.RegularExpressions.Regex]::Escape("\"),"/" )
		$ImageInfo += $('myGlobal.imageInfo["'+ $imagePath  + '"]={width=' + $png.Width + ', height=' + $png.Height + '}')
		$png.Dispose()
	}
	$ImageInfo | Out-File -Force -FilePath $($gfxFolder + "\imageInfo.lua" ) -Encoding ascii
}
#-----------------------------------------------------------------------
Add-Type -As System.IO.Compression.FileSystem
function Create-ModArchive {
	param(
		 [string]$DestinationPath
		,[string]$SubFolder
		,[string]$SourceFolder
	)
	$sourcePath = (Get-Item $SourceFolder).FullName
	$archive = [System.IO.Compression.ZipFile]::Open($DestinationPath, "Create")
	[System.IO.Compression.CompressionLevel]$compression = "Optimal"

	Get-ChildItem -Recurse $SourceFolder.TrimEnd('\') | where { (! $_.PSIsContainer) -and ($_.Name -NotLike "*.ps1") -and ($_.BaseName -ne "") } | %{
		$relPath = $($SubFolder + ($_.FullName -replace $("^"+[System.Text.RegularExpressions.Regex]::Escape($sourcePath)),''))
		$relPath = $($relPath -replace ([System.Text.RegularExpressions.Regex]::Escape("\")),"/")
		Write-verbose $relPath
		$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $_.FullName, $relPath, $compression)
	}
	$archive.Dispose()
}
#-----------------------------------------------------------------------
function Deploy-Mod {
	param(
		 [string]$modFolder
	)
	$modFolder = $modFolder.TrimEnd("\")
	If(!(test-path $modFolder)){
		Write-Host "Source Folder $modFolder not found"
		return
	}
	$modInfo = (Get-Content -Path "$modFolder\info.json" | ConvertFrom-Json)
	#-----------------------------------------------------------------------
	$modFullName = $($modInfo.name + "_" + $modInfo.version)
	Build-ImageInfo -modName $modInfo.name  -gfxFolder "$modFolder\Graphics\"
    $modArchivePath = $($env:APPDATA +  "\Factorio\mods\" + $modFullName + ".zip")
	If(test-path $modArchivePath)
	{
		Remove-Item -path $modArchivePath
	}
	#-----------------------------------------------------------------------
	Create-ModArchive -SourceFolder "$modFolder" -DestinationPath $modArchivePath -SubFolder $modInfo.name
    copy-item -path $modArchivePath -Destination C:\Daten\Dropbox\Filetransfer\nK\Games\Factorio\Mods\
}
#-----------------------------------------------------------------------
function Get-SteamFolder () {
	$steamFolder = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Valve\Steam' -Name InstallPath).InstallPath
	if ((Test-Path $steamFolder) -eq $false) {
		return (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam' -Name InstallPath).InstallPath
	}
	return $steamFolder
}
#=======================================================================
Deploy-Mod -modFolder $baseDirectory
#-----------------------------------------------------------------------
$steamFolder = Get-SteamFolder
&"$steamFolder\steam.exe" -applaunch 427520

