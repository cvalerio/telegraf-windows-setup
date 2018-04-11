if(!(Get-Command choco -errorAction SilentlyContinue)){
	Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco install -y telegraf

function Read-Host-With-Default($prompt, $default) {
	if(($result = Read-Host "$prompt [$default]") -eq ''){
	return $default
	}else{
	return $result
	}
}

$conftemplate = '.\telegraf.conf.template'
$confdestination = 'c:\Program Files\telegraf\telegraf.conf'

wget https://raw.githubusercontent.com/cvalerio/telegraf-windows-setup/master/telegraf.conf.template -outfile $conftemplate

$dbhost = Read-Host-With-Default 'InfluxDB Server' 'http://localhost:8089'
$dbname = Read-Host-With-Default 'DB name' 'telegraf'
$dbusername = Read-Host-With-Default 'DB user name' ''
$dbpassword = Read-Host-With-Default 'DB pass word' ''
$hostname = Hostname
$hostname = Read-Host-With-Default 'This host name' $hostname

copy $confdestination "$confdestination.copy"

(Get-Content $conftemplate) | Foreach-Object {
    $_ -replace '{{DB_HOST}}', $dbhost `
       -replace '{{DB_NAME}}', $dbname `
       -replace '{{DB_USER_NAME}}', $dbusername `
       -replace '{{DB_PASS_WORD}}', $dbpassword `
       -replace '{{HOSTNAME}}', $hostname
    } | Set-Content $confdestination
	
net start telegraf