[CmdletBinding()]
param(
       [Parameter(Mandatory=$True,Position=0)] 
       [string]$state
     )

[array]$services = $null

$services += new-object PsObject -property @{"startorder"=1;"stoporder"=6;"ServiceDisplayName"="Enterprise Vault Shopping Service"}
$services += new-object PsObject -property @{"startorder"=2;"stoporder"=5;"ServiceDisplayName"="Enterprise Vault Indexing Service"}
$services += new-object PsObject -property @{"startorder"=3;"stoporder"=4;"ServiceDisplayName"="Enterprise Vault Task Controller Service"}
$services += new-object PsObject -property @{"startorder"=4;"stoporder"=2;"ServiceDisplayName"="Enterprise Vault Storage Service"}
$services += new-object PsObject -property @{"startorder"=5;"stoporder"=1;"ServiceDisplayName"="Enterprise Vault Directory Service"}
$services += new-object PsObject -property @{"startorder"=6;"stoporder"=3;"ServiceDisplayName"="Enterprise Vault Admin Service"}


function Service-Control($Name,$state)
{
    $svc = Get-Service -DisplayName $Name
    $svc.WaitForStatus($state,'00:01:00') #Waits one minutes for the service to stop.
    #write-host $svc.Status
    if($svc.status -eq $state){
        write-host "Service: '$name' is $state." -ForegroundColor Green
    }else{
        Write-Host "Waiting for service $name to be $state." -ForegroundColor Red
    }

}

switch ($state)
    {
     "stop" 
            {
            write-host "====== Stopping services... ======"
            $services | Sort-Object StopOrder | #Sorts by number 
                ForEach-object {write-host "Stopping" $_.ServiceDisplayName "..."; stop-service -DisplayName $_.ServiceDisplayName -Force -warningAction SilentlyContinue;  Service-Control -Name $_.ServiceDisplayName -state "Stopped" }
                Write-host "====== Services Stopped! ======" -ForegroundColor Green
            }
     "start"
            {
             write-host "====== Starting services... ======="
            $services | Sort-Object StartOrder | 
                ForEach-object {write-host "Starting" $_.ServiceDisplayName "..."; start-service -DisplayName $_.ServiceDisplayName -warningAction SilentlyContinue; Service-Control -Name $_.ServiceDisplayName -state "Running"}
                Write-host "====== Services Started! ======" -ForegroundColor Green
            } 
     "restart"
            {
            Write-Host "====== Restarting Services... ======"
            $services | Sort-Object StopOrder | 
                ForEach-object {stop-service -DisplayName $_.ServiceDisplayName -Force -warningAction SilentlyContinue; Service-Control -Name $_.ServiceDisplayName -state "Stopped"}
                Write-host "===== Services Stopped! ======" -ForegroundColor Green
            
            $services | Sort-Object StartOrder | 
                ForEach-object {start-service -DisplayName $_.ServiceDisplayName -warningAction SilentlyContinue; Service-Control -Name $_.ServiceDisplayName -state "Running"}
                Write-host "====== Services Restarted! =======" -ForegroundColor Green
            }
     default {"Please select an action of either stop, start or restart"}
     }
     
