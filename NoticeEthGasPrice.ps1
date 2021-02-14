
# requires OutSpeech and BurntToast modules
do
{
    $gP = Get-EthGasOracle
    $stamp = Get-Date -Format yyyyMMddhhmmss
    switch ($gP.SafeGasPrice)
    {
        { [int]$_ -lt 100 }
        {
            $Notification = "$Stamp Ethereum gas is cheap: $_"
            Out-Speech $Notification
            New-BurntToastNotification -Text $Notification
        }
        default
        {
            "$stamp Ethereum gas is not cheap: $_"
        }
    }
    Start-Sleep -Seconds 30
} until ($false)