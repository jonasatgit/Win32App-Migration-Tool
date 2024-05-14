    #region function Get-DecodedJwt 
    # Function to decode access token
    function Get-DecodedJwt 
    {
        param(
            [Parameter(Mandatory=$true)]
            [string] $token
        )
    
        $parts = $token.Split('.')
        if ($parts.Count -ne 3) {
            throw "Invalid JWT token"
        }
    
        $payload = $parts[1]
        $payload = $payload.PadRight(([math]::Truncate($payload.Length / 4) + 1) * 4, '=')
        $bytes = [Convert]::FromBase64String($payload)
        $json = [Text.Encoding]::UTF8.GetString($bytes)
    
        return (ConvertFrom-Json $json)
    }
    #endregion