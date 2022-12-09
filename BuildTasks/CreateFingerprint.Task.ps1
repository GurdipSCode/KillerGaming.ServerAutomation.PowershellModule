Import-Module ".\$ModuleName"
$commandList = Get-Command -Module $ModuleName
Remove-Module $ModuleName

Write-Output 'Calculating fingerprint'
$fingerprint = foreach ( $command in $commandList )
{
    foreach ( $parameter in $command.parameters.keys )
    {
        '{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
        $command.parameters[$parameter].aliases | 
            Foreach-Object { '{0}:{1}' -f $command.name, $_}
    }
}