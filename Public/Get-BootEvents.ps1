function Get-BootEvents {
    <#
    .SYNOPSIS
    Gathers events related to and surrounding system startup and shutdown.

    .DESCRIPTION
    Lists events related to system startup and shutdown. This includes events such as kernel boot,
    power events, and system errors. This is useful for understanding why a system started or
    shutdown.

    .PARAMETER Computername
    The computer you wish to search. Defaults to $env:COMPUTERNAME. Requires RPC to be available

    .EXAMPLE
    Get-BootEvents -Computername SERVER01

    .NOTES
    Written by https://github.com/sdwheeler
    #>
    param(
        $ComputerName = "$ENV:COMPUTERNAME"
    )
    $ErrorActionPreference = 'SilentlyContinue'
    $queries = @(
        "*[System[Provider[@Name='Application Popup'] and (EventID=26)]]",
        "*[System[Provider[@Name='EventLog'] and (EventID=6008 or EventID=6005 or EventID=6006)]]",
        "*[System[Provider[@Name='Microsoft-Windows-Kernel-Boot'] and (EventID=20)]]",
        "*[System[Provider[@Name='Microsoft-Windows-Kernel-General'] and (EventID=12 or EventID=13)]]",
        "*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and (EventID=109 or EventID=41)]]",
        "*[System[Provider[@Name='Microsoft-Windows-WER-SystemErrorReporting'] and (EventID=1001)]]",
        "*[System[Provider[@Name='USER32'] and (EventID=1076 or EventID=1073)]]"
    )

    $queries |
        ForEach-Object {
            $getWinEventSplat = @{
                LogName = 'System'
                ComputerName = $ComputerName
                FilterXPath = $_
            }
            Get-WinEvent @getWinEventSplat
        } |
        Sort-Object TimeCreated -Descending |
        Select-Object TimeCreated, ProviderName, Id, UserId, Message
}