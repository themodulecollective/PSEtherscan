function Get-EthSGasOracle
{
    [cmdletbinding()]
    param(
        [string]$EtherscanAPIKey = $EtherscanAPIKey
    )

    $BaseURI = 'https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey='
    $URIWithKey = $BaseURI + $EtherscanAPIKey
    $Result = $(Invoke-WebRequest -URI $URIWithKey).Content | ConvertFrom-Json
    $Result.Result

}