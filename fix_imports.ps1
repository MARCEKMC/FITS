# Script para corregir imports masivamente
Write-Host "Corrigiendo imports restantes..."

# Función para actualizar archivos
function Fix-Imports {
    param($FilePath, $OldPattern, $NewPattern)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content -match [regex]::Escape($OldPattern)) {
            $newContent = $content -replace [regex]::Escape($OldPattern), $NewPattern
            Set-Content $FilePath $newContent -NoNewline
            Write-Host "Fixed: $FilePath"
        }
    }
}

# Corregir imports de data en viewmodels
Get-ChildItem -Recurse "c:\fits\lib\modules" -Filter "*_viewmodel.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Corregir imports de modelos
    $content = $content -replace "import '../data/models/", "import '../../../data/models/"
    $content = $content -replace "import '../data/repositories/", "import '../../../data/repositories/"
    $content = $content -replace "import '../data/services/", "import '../../../data/services/"
    
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Updated viewmodel: $($_.FullName)"
}

# Corregir imports de widgets en screens
Get-ChildItem -Recurse "c:\fits\lib\modules" -Filter "*_screen.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Corregir imports de widgets dentro del mismo módulo
    $content = $content -replace "import '../../widgets/[^/]+/", "import '../widgets/"
    
    Set-Content $_.FullName $content -NoNewline
    Write-Host "Updated screen: $($_.FullName)"
}

Write-Host "Imports corregidos!"
