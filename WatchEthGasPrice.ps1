#LocalSpeech notification requires Windows PowerShell and the OutSpeech module
#LocalNotification requires BurntToast Module and running on Windows OS
#IFTTT Notification requires configuration of a webhook app in your IFTTT account
function Send-IftttRichNotification
{
    #Attribution: https://www.dennisrye.com/post/send-smartphone-notifications-powershell-ifttt/
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$EventName,

        [Parameter(Mandatory)]
        [string]$Key,

        [string]$Value1,

        [string]$Value2,

        [string]$Value3
    )

    $webhookUrl = "https://maker.ifttt.com/trigger/{0}/with/key/{1}" -f $EventName, $Key

    $body = @{
        value1 = $Value1
        value2 = $Value2
        value3 = $Value3
    }

    Invoke-RestMethod -Method Get -Uri $webhookUrl -Body $body
}

function Watch-EthGasPrice
{
    [cmdletbinding()]
    param(
        [int]$MaxPrice = 91
        ,
        [int]$SleepSeconds = 30
        ,
        [parameter()]
        [ValidateSet('LocalSpeech', 'LocalNotification', 'IFTTTNotification')]
        [string[]]$NotificationType
        ,
        [string]$IFTTTEventName
        ,
        [string]$IFTTTKey
    )

    do
    {
        $gP = Get-EthSGasOracle
        $stamp = Get-Date -Format yyyyMMddhhmmss
        switch ($gP.SafeGasPrice)
        {
            { [int]$_ -le $MaxPrice }
            {
                [int]$price = $_
                $NotificationText = "Ethereum gas price is $price"
                switch ($NotificationType)
                {
                    'LocalSpeech'
                    {
                        Out-Speech $NotificationText
                    }
                    'LocalNotification'
                    {
                        $BTNotification = $NotificationText + " $stamp"
                        New-BurntToastNotification -Text $BTNotification
                    }
                    'IFTTTNotification'
                    {
                        Send-IftttRichNotification -EventName $IFTTTEventName -Key $IFTTTKey -Value1 'Eth Gas Price Low' -Value2 $price -Value3 'https://etherscan.io/gastracker'
                    }
                }
            }
            default
            {
                "$stamp Ethereum gas is NOT cheap. Gas price is $_"
            }
        }
        Start-Sleep -Seconds $SleepSeconds
    } until ($false)
}
