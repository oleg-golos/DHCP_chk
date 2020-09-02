## html formatting style ##
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"
## html formatting style ##

# First DHCP server name
$DHCP_1 = "DHCP-01"
# Second DHCP server name
$DHCP_2 = "DHCP-02"
# SMTP server
$SmtpServer = "smtp.domain.com"
# Recipients emails
$Receps = @("admin@domain.com")
# Sender email
$Sender = "dhcp@domain.com"

# Get DHCP scopes from the first server
$local = Get-DhcpServerv4Scope -ComputerName DHCP-01| select scopeid,state,description
# Get DHCP scopes from the second server
$remote = Get-DhcpServerv4Scope -ComputerName DHCP-02 | select scopeid,state
# Compare the scopes and send a list of differences, if present, to a specified email
if ($remote -ne $null) {
    $result = $null
    $result = @()
    foreach ($scope_01 in $local) {
        $scope_02 = $remote | ? scopeid -eq $scope_01.scopeid
        if (($scope_02 -eq $null) -or ($scope_01.state -ne $scope_02.state)) {
            $result += new-object -TypeName PSObject -Property @{"scope"=$scope_01.ScopeId;"state_01"=$scope_01.state;"state_02"=$scope_02.state}
            }
        }
    $result | select scope, state_01, state_02, desc
    if ($result -ne $null) {
        $message = $result | select scope, state_01, state_02 | ConvertTo-Html -Head $style | Out-String
        Send-MailMessage -Body $message -BodyAsHtml  -From $Sender -To $receps -SmtpServer $SmtpServer -Subject "DHCP Scopes Inconsistency Report"
        }
    }