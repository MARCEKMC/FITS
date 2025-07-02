# Script para actualizar todos los imports después de la reorganización

# Función para actualizar imports en archivos
function Update-Imports {
    param(
        [string]$Path,
        [hashtable]$Replacements
    )
    
    Get-ChildItem -Recurse $Path -Filter "*.dart" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $updated = $false
        
        foreach ($old in $Replacements.Keys) {
            if ($content -match [regex]::Escape($old)) {
                $content = $content -replace [regex]::Escape($old), $Replacements[$old]
                $updated = $true
            }
        }
        
        if ($updated) {
            Set-Content $_.FullName $content -NoNewline
            Write-Host "Updated: $($_.FullName)"
        }
    }
}

# Definir los reemplazos para viewmodels
$viewmodelReplacements = @{
    "import '../../../viewmodel/auth_viewmodel.dart';" = "import '../../../modules/auth/viewmodels/auth_viewmodel.dart';"
    "import '../../../viewmodel/user_viewmodel.dart';" = "import '../../../modules/profile/viewmodels/user_viewmodel.dart';"
    "import '../../../viewmodel/health_viewmodel.dart';" = "import '../../../modules/health/viewmodels/health_viewmodel.dart';"
    "import '../../../viewmodel/food_viewmodel.dart';" = "import '../../../modules/health/viewmodels/food_viewmodel.dart';"
    "import '../../../viewmodel/water_viewmodel.dart';" = "import '../../../modules/health/viewmodels/water_viewmodel.dart';"
    "import '../../../viewmodel/exercise_viewmodel.dart';" = "import '../../../modules/health/viewmodels/exercise_viewmodel.dart';"
    "import '../../../viewmodel/notes_viewmodel.dart';" = "import '../../../modules/efficiency/viewmodels/notes_viewmodel.dart';"
    "import '../../../viewmodel/secure_notes_viewmodel.dart';" = "import '../../../modules/efficiency/viewmodels/secure_notes_viewmodel.dart';"
    "import '../../../viewmodel/tasks_viewmodel.dart';" = "import '../../../modules/efficiency/viewmodels/tasks_viewmodel.dart';"
    "import '../../../viewmodel/statistics_viewmodel.dart';" = "import '../../../modules/efficiency/viewmodels/statistics_viewmodel.dart';"
    "import '../../../viewmodel/fitsi_chat_viewmodel.dart';" = "import '../../../modules/fitsi/viewmodels/fitsi_chat_viewmodel.dart';"
    "import '../../../viewmodel/selected_date_viewmodel.dart';" = "import '../../../shared/viewmodels/selected_date_viewmodel.dart';"
}

# Actualizar imports en archivos ui que quedaron
Update-Imports -Path "c:\fits\lib\ui" -Replacements $viewmodelReplacements

# Reemplazos para screens y widgets
$screenReplacements = @{
    "import '../health/food_main_screen.dart';" = "import '../../../modules/health/screens/food_main_screen.dart';"
    "import '../health/exercise_main_screen.dart';" = "import '../../../modules/health/screens/exercise_main_screen.dart';"
    "import '../efficiency/schedule_screen.dart';" = "import '../../../modules/efficiency/screens/schedule_screen.dart';"
    "import '../efficiency/notes_screen.dart';" = "import '../../../modules/efficiency/screens/notes_screen.dart';"
    "import '../efficiency/reports_screen.dart';" = "import '../../../modules/efficiency/screens/reports_screen.dart';"
}

Update-Imports -Path "c:\fits\lib\ui" -Replacements $screenReplacements

Write-Host "Import updates completed!"
