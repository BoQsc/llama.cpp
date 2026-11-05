param(
    [string]$BaseUrl = 'http://127.0.0.1:8080/v1',
    [string]$ModelAlias = 'spark-dspark',
    [string]$ApiKey = ''
)
$ErrorActionPreference = 'Stop'
$body = @{
    model = $ModelAlias
    messages = @(@{ role = 'user'; content = 'Reply with one short greeting.' })
    temperature = 1.0
    top_p = 0.95
    max_tokens = 64
    stream = $false
} | ConvertTo-Json -Depth 5
$headers = @{}
if ($ApiKey -ne '') { $headers['Authorization'] = "Bearer $ApiKey" }
try {
    $response = Invoke-RestMethod -Method Post -Uri ($BaseUrl.TrimEnd('/') + '/chat/completions') -ContentType 'application/json' -Headers $headers -Body $body
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Error "API request failed. Is start-dspark.cmd running? $($_.Exception.Message)"
    exit 1
}
