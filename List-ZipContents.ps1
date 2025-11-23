<#
.SYNOPSIS
    Lists the contents of a ZIP file.

.EXAMPLE
    .\List-ZipContents.ps1 -ZipPath .\Your.zip
    
.NOTES
    Author: Kingston Damour
    Date: 2025-11-23
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$ZipPath
)

# First, make sure the path exists
if (-not (Test-Path -LiteralPath $ZipPath)) {
    Write-Error "ZIP file not found: $ZipPath"
    exit 1
}

try {
    # Normalize to a full filesystem path so .\ and ..\ work
    $ZipPath = (Resolve-Path -LiteralPath $ZipPath).ProviderPath
}
catch {
    Write-Error "Failed to resolve path '$ZipPath'. $_"
    exit 1
}

try {
    # Load ZIP assembly (needed in Windows PowerShell 5.1; PS 7+ usually has it already)
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
} catch {
    Write-Error "Failed to load System.IO.Compression.FileSystem assembly. $_"
    exit 1
}

# Open the ZIP in read-only mode
$zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)

try {
    $zip.Entries |
        Select-Object `
            @{Name = 'FullName';         Expression = { $_.FullName }}, `
            @{Name = 'UncompressedSize'; Expression = { $_.Length }}, `
            @{Name = 'CompressedSize';   Expression = { $_.CompressedLength }}, `
            @{Name = 'LastWriteTime';    Expression = { $_.LastWriteTime.LocalDateTime }} |
        Sort-Object FullName |
        Format-Table -AutoSize
}
finally {
    $zip.Dispose()
}
