param(
    [string]$TargetModel = 'models\Spark-target.gguf',
    [string]$DraftModel = 'models\Spark-draft.gguf',
    [string]$ModelAlias = 'spark-dspark',
    [int]$Context = 8192,
    [int]$Threads = 8,
    [string]$HostAddress = '127.0.0.1',
    [int]$Port = 8080,
    [string]$ApiKey = '',
    [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = 'Stop'
function Resolve-ModelPath([string]$Path) {
    if ([System.IO.Path]::IsPathRooted($Path)) { return $Path }
    return (Join-Path $PSScriptRoot $Path)
}

$exe = Join-Path $PSScriptRoot 'llama-server.exe'
$target = Resolve-ModelPath $TargetModel
$draft = Resolve-ModelPath $DraftModel
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
    throw 'llama-server.exe not found. Download and extract a compiled GitHub Release ZIP.'
}
if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
    throw "Target GGUF not found: $target"
}
if (-not (Test-Path -LiteralPath $draft -PathType Leaf)) {
    throw "DSpark draft GGUF not found: $draft"
}

$serverArgs = @(
    '-m', $target, '-md', $draft,
    '--alias', $ModelAlias,
    '--spec-type', 'draft-dspark',
    '--spec-draft-n-max', '7',
    '--spec-draft-p-min', '0',
    '-ngl', '999', '-ngld', '999',
    '-ctk', 'f16', '-ctv', 'f16',
    '-ctkd', 'f16', '-ctvd', 'f16',
    '-fa', 'on',
    '-c', [string]$Context, '-np', '1',
    '-b', '2048', '-ub', '512',
    '-t', [string]$Threads,
    '--jinja',
    '--host', $HostAddress, '--port', [string]$Port
)
if ($ApiKey -ne '') { $serverArgs += @('--api-key', $ApiKey) }
if ($ExtraArgs.Count -gt 0) { $serverArgs += $ExtraArgs }

Write-Host ("OpenAI-compatible API: http://{0}:{1}/v1" -f $HostAddress, $Port)
Write-Host "Model ID: $ModelAlias"
Write-Host 'Stop with Ctrl+C'
& $exe @serverArgs
exit $LASTEXITCODE
