sa-win
======

Two liner to prepare windows server for ansible provisioning and connecting to winrm session over ssh protocol from linux box

Note: repo Includes 3rd party work - copy of https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
All rights for that file/code portion are reserved to original authors (repo is under GNU General Public License v3.0)


```ps

Set-ExecutionPolicy Bypass -Scope Process -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/softasap/sa-win/master/bootstrap.ps1'))
```

or

```ps

Set-ExecutionPolicy Bypass -Scope Process -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/softasap_win'))
```


# Validating ansible connectivity

Check box-example for hosts.example


If everything completed smoothly, you should be able to run following test below


Note: dependency - python pywinrm package

```
pip install pywinrm
```

hostsfile can be kind of

```
[win]
192.168.2.145

[win:vars]
ansible_user=vagrant
ansible_password=password
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
```

```sh
ansible windows -i hosts -m win_ping


192.168.2.145 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```


# Validating winrm over ssh connectivity


If for whatever reasons you want to connect interactively from linux box, things get more complicated.

So you need to install Powershell 6.x on remote server together with OpenSSHServer 
(Gets installed using GetPowershell6LinuxRemoting.ps1 by default with this play)

than you need also to install Powershell 6.x for ubuntu or your distribution

```sh
# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb

# Update the list of products
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

# Start PowerShell
pwsh
```


If you configured everything right, you should be able to invoke:

```pwsh

$session = New-PSSession -HostName 192.168.2.145 -UserName Administrator


 $session                                                                
 Id Name            Transport ComputerName    ComputerType    State         Con
                                                                            fig
                                                                            ura
                                                                            tio
                                                                            nNa
                                                                            me
 -- ----            --------- ------------    ------------    -----         ---
  2 Runspace1       SSH       192.168.2.145   RemoteMachine   Opened        Def


PS /home/slavko> Enter-PSSession $session                                                           
[Administrator@192.168.2.145]: PS C:\Users\Administrator\Documents> 

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         1/2/2019   6:51 AM                WindowsPowerShell
```


But if you do not need to use some specific powershell functionality, you also can do smth as simple as

```
ssh administrator@192.168.2.145
```
