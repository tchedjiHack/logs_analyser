<#
.SYNOPSIS
    Script d'analyse des journaux Windows Logs.

.DESCRIPTION
    Ce script permet de lister, filtrer et exporter les événements des journaux Windows.

.AUTEUR
    Tej

.DATE
    25/02/2025 16:15
#>

function Logs_Listing {
    # Listing logs followed by numbers
    $logs = Get-WinEvent -ListLog * | Select-Object LogName
    Write-Host "Liste des journaux : "
    Start-Sleep 1
    for ($i = 1; $i -le $logs.Count; $i++) {
        Write-Host "
        $i. $($logs[$i - 1].LogName)"
    }
    Write-Host "Nous avons au total $($logs.Count) journaux." 
    Return_to_Origin
}
function Return_to_Origin {
    $return = Read-Host -Prompt "Revenir au départ ? (O/N)"
    if ($return -eq 'O') {
        Options
    } else {
        Write-Host "Bye!"
        break
    }
}

function Option_Choice {
    $choice = Read-Host -Prompt "Option ... "

    switch ($choice) {
        1 { 
            Logs_Listing
        }
        2 {
            X_last_events
        }
        3 {
            Filter_Logs
        }
        4 {
            Saving_To_Txt
        }
        5 {
            Write-Host "Pas de confirmation ! Au revoir $global:username !"
            break
        }
        Default {
            "Rien à faire. Goodbye !"
            break
        }
    }
}

function Options {
    Write-Host "
    1. Lister tous les journaux disponibles
    2. Afficher les x derniers événements d'un journal donné
    3. Filtrer les événements en fonction d'une période et d'un ID spécifique et exporter les résultats dans un fichier CSV
    4. Enregistrer les événements récents dans un fichier texte
    5. Quitter
    "
    Option_Choice
}

function X_last_events {
    # Displaying 10 last events of a log according to admin choice.
        $logs_list = Get-WinEvent -ListLog * | Select-Object LogName
        $logs_list | ForEach-Object -Begin { $i = 1 } -Process { Write-Host "$i. $($_.LogName)"; $i++ }
           
        do {
            $valid_number = $true
            [int32]$chosen_number = Read-Host -Prompt "Entrez un numéro de journal (entre 1 et 393) "
            if ($chosen_number -lt 1 -or $chosen_number -gt $logs_list.Count) {
                $valid_number = $false
                Write-Host "❌ Réponse rejetée avec succès. Reste dans la plage définie."
            } 
        } while (-not $valid_number)
        

        [int32]$x = Read-Host -Prompt "Nombre de derniers événements "
        
        $chosen_log = $(($logs_list[$chosen_number - 1]).LogName)

        Write-Host "Vous avez choisi le journal $chosen_log"
        Start-Sleep 1
        
        Write-Host "Récupération des $x derniers événements : "
        Start-Sleep 1

        try {
            $events = Get-WinEvent -LogName $chosen_log -MaxEvents $x -ErrorAction Stop
            $events
        }
        catch {
            Write-Host "Pas d'événements dans ce journal..." -ForegroundColor Blue
        }
    Return_to_Origin
}

function Filter_Logs {
        $logs_list = Get-WinEvent -ListLog * | Select-Object LogName
        $logs_list | ForEach-Object -Begin { $i = 1 } -Process { Write-Host "$i. $($_.LogName)"; $i++ }
           
        do {
            $valid_number = $true
            [int32]$chosen_number = Read-Host -Prompt "Entrez un numéro de journal (entre 1 et 393) "
            if ($chosen_number -lt 1 -or $chosen_number -gt $logs_list.Count) {
                $valid_number = $false
                Write-Host "❌ Réponse rejetée avec succès. Veuillez rester dans la plage définie."
            } 
        } while (-not $valid_number)

        $chosen_log = $(($logs_list[$chosen_number - 1]).LogName)

        while ($true) {
            try {
                $start_date = Read-Host -Prompt "Date de début (JJ/MM/AAAA)"
                $end_date = Read-Host -Prompt "Date de fin (JJ/MM/AAAA)"
                [int]$id = Read-Host -Prompt "Une idée de l'ID de l'événement ? "
    
                $date1 = [datetime]::ParseExact($start_date, "dd/MM/yyyy", $null)
                $date2 = [datetime]::ParseExact($end_date, "dd/MM/yyyy", $null)
    
                if ($date2 -lt $date1) {
                    Write-Host "Impossible de poursuivre. La date de fin doit être postérieure à la date de début."
                    continue
                }
    
                if ($id -lt 0) {
                    Write-Host "❌ Valeur invalide."
                    continue
                } 
    
                Write-Host "✅ Date valide : $($date1.ToString("dd/MM/yyyy"))"
                Write-Host "✅ Date valide : $($date2.ToString("dd/MM/yyyy"))"
                break
            } catch {
                Write-Host "❌ Valeur invalide ! Veuillez recommencer..." -ForegroundColor Yellow
            }
        }
    
        try {
            $last_events = Get-WinEvent -FilterHashtable @{
                LogName = $chosen_log; 
                StartTime = $date1; 
                EndTime = $date2; 
                ID = $id
            } -ErrorAction Stop
        
            if($last_events -eq 0) {
                Write-Host "Aucun résultat."
            } else {
                $temp = $last_events | Select-Object TimeCreated, Id, Message
                Write-Host "Veuillez consulter le fichier my_last_results.csv."
                $temp | Export-Csv -Path ".\my_last_results.csv" -NoTypeInformation
            }
        } catch {
            Write-Host "❌ Erreur lors de la récupération des données."
        }
    Return_to_Origin
}

function Saving_To_Txt {
    $logs_list = Get-WinEvent -ListLog * | Select-Object LogName
    $logs_list | ForEach-Object -Begin { $i = 1 } -Process { Write-Host "$i. $($_.LogName)"; $i++ }
        
    do {
        $valid_number = $true
        [int32]$chosen_number = Read-Host -Prompt "Entrez un numéro de journal (entre 1 et 393) "
        if ($chosen_number -lt 1 -or $chosen_number -gt $logs_list.Count) {
            $valid_number = $false
            Write-Host "❌ Réponse rejetée avec succès. Veuillez rester dans la plage définie."
        } 
    } while (-not $valid_number)

    $chosen_log = $(($logs_list[$chosen_number - 1]).LogName)

    try {
        $events_to_save = Get-WinEvent -LogName $chosen_log -ErrorAction Stop
        Start-Sleep 3
        $events_to_save
    } catch {
        Write-Host "Aucun événement particulier pour ce journal."
    }
    $events_to_save | Out-File -Path ".\recent_events.txt"

    Return_to_Origin
}

function main {
    Write-Host "Bienvenue sur l'interface de gestion des journaux Windows." -ForegroundColor Blue
    [String]$global:username = Read-Host -Prompt "Entrez votre prénom s'il vous plait "
    Write-Host "Alors, $global:username, choisis parmi les options suivantes : "
    Options
}

if ($MyInvocation.InvocationName -ne '.') {
    main
}
