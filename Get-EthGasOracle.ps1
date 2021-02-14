function Get-EthGasOracle
{
    [cmdletbinding()]
    param([string]$EtherscanAPIKey)

    $BaseURI = 'https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey='
    $URIWithKey = $BaseURI + $EtherscanAPIKey
    $Result = $(Invoke-WebRequest -URI $URIWithKey).Content | ConvertFrom-Json
    $Result.Result

}