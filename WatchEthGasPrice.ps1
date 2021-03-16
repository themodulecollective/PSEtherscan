#LocalSpeech notification requires Windows PowerShell and the OutSpeech module
#LocalNotification requires BurntToast Module and running on Windows OS
#IFTTT Notification requires configuration of a webhook app in your IFTTT account

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
        [string]$EventName
        ,
        [string]$Key
        ,
        [string]$EtherscanAPIKey
        ,
        [parameter(Mandatory)]
        [ValidateSet('SafeLow', 'Medium', 'Fast')]
        $PriceType
    )

    do
    {
        $gP = Get-EthSGasOracle -EtherscanAPIKey $EtherscanAPIKey
        $stamp = Get-Date -Format yyyyMMddhhmmss
        switch ($PriceType)
        {
            'SafeLow'
            { $Price = $gP.SafeGasPrice }
            'Medium'
            { $Price = $gP.ProposeGasPrice }
            'Fast'
            { $Price = $gP.FastGasPrice }
        }

        $NotificationText = "Ethereum gas price is $Price"

        switch ($Price)
        {
            { [int]$_ -le $MaxPrice }
            {
                [int]$price = $_
                Write-Information -MessageData "$stamp $NotificationText" -InformationAction Continue
                switch ($NotificationType)
                {
                    'LocalSpeech'
                    {
                        Out-Speech $NotificationText
                    }
                    'LocalNotification'
                    {
                        $BTNotification = "$stamp $NotificationText. Threshold $MaxPrice."
                        New-BurntToastNotification -Text $BTNotification
                    }
                    'IFTTTNotification'
                    {
                        Send-IftttRichNotification -EventName $EventName -Key $Key -Value1 "$NotificationText. Threshold $MaxPrice" -Value2 $price -Value3 'https://etherscan.io/gastracker'
                    }
                }
            }
            default
            {
                Write-Information -MessageData "$stamp $NotificationText. Threshold $MaxPrice" -InformationAction Continue
            }
        }
        Start-Sleep -Seconds $SleepSeconds
    } until ($false)
}
