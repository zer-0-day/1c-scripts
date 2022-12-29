#Стартовое меню
function StartMenu {
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "Выбор функции" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "1. Полная установка (нет и не было сервера 1С)" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "2. Только установка или обновление платформы" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "3. Создать ссылки current" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "4. Справка" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "q. Exit" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host
    
       while($true)
    {
    $choice = Read-Host "Select the menu item"
    
    Switch($choice){
    1{FullInstall}
    2{Write-Host "В доработке"}
    3{MakeLinks}
    4{Write-Host "Справки пока нет"}
    q{Write-Host "q"; return}
    default {Write-Host "Wrong choice, try again." -ForegroundColor Red}
    }
    }
      
}
# Сбор информации при старте скрипта        
function StartInfo {
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 Write-host "Запрос и сортировка версий 1С" -BackgroundColor Black -ForegroundColor Green
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 $install1CVersion = Get-WmiObject Win32_Product | Where-Object {$_.Name -match "^(1С|1C)"} 
 $ListVersion = $install1CVersion.Name -replace '1С:Предприятие 8' , ''  -replace 'Тонкий клиент', '' -replace '[(]' , '' -replace '[)]' , '' -replace 'x86-64' , '' -replace ' ' , '' 
 Write-Host "Все установленные платформы 1С: " -BackgroundColor Black -ForegroundColor Green
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 $ListVersion |Sort-Object -Descending
 $LastVersion = $ListVersion |Sort-Object -Descending |Select-Object -First 1
 Write-Host "Последняя установленная версия платформы 1С:" -BackgroundColor Black -ForegroundColor Green
 $LastVersion
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 
 # Проверка существования только одной версии файла ragent.exe 
    #Проверка существования ссылки Current.
 if (Test-Path -Path "C:\Program Files\1cv8\current\") {
    $Ragentx64 = Test-Path -Path "C:\Program Files\1cv8\current\bin\ragent.exe"
    $Ragentx86 = Test-Path -Path "C:\Program Files (x86)\1cv8\current\bin\ragent.exe"
    $Ragentx64 -eq $Ragentx86
if ($Ragentx64 -eq $Ragentx86) {
    if ((Get-Item "C:\Program Files\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion -eq (Get-Item "C:\Program Files (x86)\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion) {
    Write-Host "Корректная работа скрипта не гарантируется!" -BackgroundColor Black -ForegroundColor Red
    Write-Host "Обнаружены два исполняемых файла сервера 1С одной версии и разной разрядности (32 и 64 бит)." -BackgroundColor Black -ForegroundColor Red
    Write-Host "Необходимо удалить лишние версии Платформы 1С"-BackgroundColor Black -ForegroundColor Red
 }
}
 }
 
 #проверка пути установки платформы
 $LastVersionPathx64 = "C:\Program Files\1cv8\" + $LastVersion
 $LastVersionPathx86 = "C:\Program Files (x86)\1cv8\" + $LastVersion
 if (Test-Path -Path $LastVersionPathx64) {
    Write-Host "Путь к последней установленной версии платформы 1С: " -BackgroundColor Black -ForegroundColor Green
    Write-Host $LastVersionPathx64  -BackgroundColor Black -ForegroundColor White
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
 }
 if (Test-Path -Path $LastVersionPathx86) {
    Write-Host "Путь к последней установленной версии платформы 1С: " -BackgroundColor Black -ForegroundColor Green  
    Write-Host $LastVersionPathx86  -BackgroundColor Black -ForegroundColor White
 }
 # Проверка существования службы 1С current и ссылки current
 # Запрос службы сервера 1С и сохранение результата запроса во временный файл
 Get-Service 1c*  >> file
 # Запрс версии сервера 1С
if (Select-String file -Pattern 'Current') {
    if (Test-Path -Path "C:\Program Files\1cv8\current\bin"){
        Write-Host "Версия сервера" -BackgroundColor Black -ForegroundColor Green 
        Write-Host (Get-Item "C:\Program Files\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
        }
    if (Test-Path -Path "C:\Program Files\1cv8 (x86)\current\bin"){
        Write-Host "Версия сервера" -BackgroundColor Black -ForegroundColor Green
        Write-Host (Get-Item "C:\Program Files (x86)\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
        }
}
else {
Write-Host 'Служба сервера с ссылкой "Current" не найдена' -BackgroundColor Black -ForegroundColor Green
}
Remove-Item file
#проверка наличия линка на директорию с дистрибутивами
if (Test-Path 'C:\1cv8.adm') {
    $DistrDirectory = 'C:\1cv8.adm'
    "Есть линк на директорию с дистрибутивами 1C"
}
elseif (Test-Path 'D:\1cv8.adm') {
    $DistrDirectory = New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target 'D:\1cv8.adm'
    "Директория с дистрибутивами 1С находится на диске D"
}
elseif (Test-Path 'E:\1cv8.adm') {
    $DistrDirectory = New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target 'E:\1cv8.adm'
    "Директория с дистрибутивами 1С находится на диске E"
}
elseif ($GetPath = Read-Host 'Директория с дистрибутивами 1С не найдена. Введите путь к папке 1cv8.adm') {
    $DistrDirectory = New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target $GetPath
}

}
# Запрос существования пользователя  USR1CV8
function  UserAvailability ($CheckUser) {
    $CheckUser = Read-host "Есть ли пользователь?"
    if ($CheckUser -eq 'Y') {
        #Пользователь существует, перейти к установке платформы
        InstallPlatform
        return
    }
    elseif ($CheckUser -eq 'N') {
        # Пользователя нет, запустить функцию создания пользователя и каталога сервера 
        CreateUser
        return
        InstallPlatform
    }
    Return
}
# Создание пользователя USR1CV8
function CreateUser {
    $username = "USR1CV8"
    $password = Read-Host "Введите пароль пользователя" -AsSecureString
    #$compName=$env:computername
    # имя компа + имя пользователя
    # $fullnameuser = $compName +'\' + $username 
    New-LocalUser "$username" -Password $password -FullName "$username" -Description "Account for 1C:Enterprise 8 Server"
    # предоставить пользователю права входа в качестве службы
    Add-Type @'
    using System;
    using System.Runtime.InteropServices;
    using System.Security.Principal;
    public class LsaUtility
    {
    [DllImport("advapi32.dll")]
    private static extern int LsaOpenPolicy(
      ref LSA_UNICODE_STRING sysName,
      ref LSA_OBJECT_ATTRIBUTES lsaObjectAttributes,
      int desiredAccess,
      out IntPtr lsaPolicyHandle);
    [DllImport("advapi32.dll", SetLastError = true)]
    private static extern int LsaAddAccountRights(
      IntPtr lsaPolicyHandle,
      IntPtr lsaAccountSid,
      LSA_UNICODE_STRING[] lsaUserRights,
      long count);
    [DllImport("advapi32.dll")]
    private static extern int LsaClose(IntPtr lsaObjectHandle);
    [DllImport("advapi32.dll")]
    private static extern int LsaNtStatusToWinError(int lsaStatus);
    public static long AddPrivilege(string sidString, string privilegeName)
    {
        LSA_UNICODE_STRING sysName = new LSA_UNICODE_STRING();
        LSA_OBJECT_ATTRIBUTES lsaAttributes = new LSA_OBJECT_ATTRIBUTES()
        {
            Length = 0,
            RootDirectory = IntPtr.Zero,
            ObjectName = new LSA_UNICODE_STRING(),
            Attributes = 0U,
            SecurityDescriptor = IntPtr.Zero,
            SecurityQualityOfService = IntPtr.Zero
        };
        int desiredAccess = 0x00F0FFF; // all access
        IntPtr lsaPolicyHandle = IntPtr.Zero;
        int status = LsaOpenPolicy(ref sysName, ref lsaAttributes, desiredAccess, out lsaPolicyHandle);
        int ntStatus = LsaNtStatusToWinError(status);
        if (ntStatus != 0)
        {
            Console.WriteLine("LsaOpenPolicy failed: " + ntStatus);
        }
        else
        {
            Console.WriteLine("LsaOpenPolicy succeeded");
            LSA_UNICODE_STRING[] lsaUserRights = new LSA_UNICODE_STRING[1]
            {
                new LSA_UNICODE_STRING()
            };
            lsaUserRights[0].lsaBuffer = Marshal.StringToHGlobalUni(privilegeName);
            lsaUserRights[0].lsaLength = (ushort)(privilegeName.Length * 2);
            lsaUserRights[0].lsaMaximumLength = (ushort)((privilegeName.Length + 1) * 2);
            SecurityIdentifier sid = new SecurityIdentifier(sidString);
            byte[] numArray = new byte[sid.BinaryLength];
            sid.GetBinaryForm(numArray, 0);
            IntPtr num2 = Marshal.AllocHGlobal(sid.BinaryLength);
            Marshal.Copy(numArray, 0, num2, sid.BinaryLength);
            try
            {
                ntStatus = LsaNtStatusToWinError(LsaAddAccountRights(lsaPolicyHandle, num2, lsaUserRights, 1L));
                if (ntStatus != 0)
                {
                    Console.WriteLine("LsaAddAccountRights failed: " + ntStatus);
                }
                else
                {
                    Console.WriteLine("LsaAddAccountRights succeeded");
                }
                LsaClose(lsaPolicyHandle);
            }
            finally
            {
                Marshal.FreeHGlobal(num2);
            }
        }
        return ntStatus;
    }
    private struct LSA_UNICODE_STRING
    {
        public ushort lsaLength;
        public ushort lsaMaximumLength;
        public IntPtr lsaBuffer;
    }
    private struct LSA_OBJECT_ATTRIBUTES
    {
        public int Length;
        public IntPtr RootDirectory;
        public LSA_UNICODE_STRING ObjectName;
        public uint Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }
}
'@
    $userSid = (New-Object System.Security.Principal.NTAccount($username)).Translate([System.Security.Principal.SecurityIdentifier]).value
    [LsaUtility]::AddPrivilege($userSid, "SeServiceLogonRight")
    
} 


#запрос разрядности устанавливаемого сервера
function GetArch {
    $Global:arch = Read-Host 'разрядность платформы'
    if ($arch -eq '32') {
        #запуск функции установки службы для x86 платформы
        CreateServicex86
    
    }   
    elseif ($arch -eq '64' ) {
        #запуск функции установки службы для x64 платформы
        CreateServicex64
    
    }  
}
#создание службы х86 сервера
function CreateServicex86 {
  
    $Version = 'Current'
    $username = "USR1CV8"
    $ServiceName = "1C:Enterprise 8.3 Server Agent $Version"
    #Запрос номера порта
    $PortNumber = Read-Host 'Ввести первые две цифры порта сервера 1С'
    #Запрос ввода логина и пароля пользователя USR1CV8                      
    $Mycreds = Get-Credential   
    $RangePort = $PortNumber + '60' + ':' + $PortNumber + '91'
    $BasePort = $PortNumber + '41'
    $CtrlPort = $PortNumber + '40'
    $SrvCatalog = "C:\Program Files (x86)\1cv8\srvinfo"
    $SrvRunCatalog = '"C:\Program Files (x86)\1cv8\srvinfo"'
    $RunPath = '"C:\Program Files (x86)\1cv8\current\bin\ragent.exe"'
    $DirectoryPath = "C:\Program Files (x86)\1cv8\current\bin\"
    $ServicePath = $RunPath + ' ' + '-srvc -agent -regport' + ' ' + $BasePort + ' ' + '-port' + ' ' + $CtrlPort + ' ' + '-range' + ' ' + $RangePort + ' ' + '-debug -d' + ' ' + $SrvRunCatalog
    $comcntrl = $DirectoryPath + 'comcntr.dll'
    $radmin = $DirectoryPath + 'radmin.dll'
    #создать службу
    New-Service -name $ServiceName -binaryPathName $ServicePath -displayName $ServiceName -startupType Automatic -credential $Mycreds
    #дать права пользователю
    $ACL = Get-Acl $SrvCatalog
    $setting = "$username", "FullControl", "Allow"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
    $ACL.SetAccessRule($AccessRule)
    $ACL | Set-Acl $SrvCatalog
    $ACL.SetAccessRuleProtection($false, $true)
    regsvr32.exe "$comcntrl" -s
    regsvr32.exe $radmin -s
    "installation completed"
    Return

}
#создание службы 64х сервера
function CreateServicex64 {
  
    $Version = 'Current'
    $username = "USR1CV8"
    $ServiceName = "1C:Enterprise 8.3 Server Agent $Version"
    #Запрос номера порта
    $PortNumber = Read-Host 'Ввести первые две цифры порта сервера 1С'
    #Запрос ввода логина и пароля пользователя USR1CV8                      
    $Mycreds = Get-Credential   
    $RangePort = $PortNumber + '60' + ':' + $PortNumber + '91'
    $BasePort = $PortNumber + '41'
    $CtrlPort = $PortNumber + '40'
    $SrvCatalog = "C:\Program Files\1cv8\srvinfo"
    $SrvRunCatalog = '"C:\Program Files\1cv8\srvinfo"'
    $RunPath = '"C:\Program Files\1cv8\current\bin\ragent.exe"'
    $DirectoryPath = "C:\Program Files\1cv8\current\bin\"
    $ServicePath = $RunPath + ' ' + '-srvc -agent -regport' + ' ' + $BasePort + ' ' + '-port' + ' ' + $CtrlPort + ' ' + '-range' + ' ' + $RangePort + ' ' + '-debug -d' + ' ' + $SrvRunCatalog
    $comcntrl = $DirectoryPath + 'comcntr.dll'
    $radmin = $DirectoryPath + 'radmin.dll'
    #создать службу
    New-Service -name $ServiceName -binaryPathName $ServicePath -displayName $ServiceName -startupType Automatic -credential $Mycreds
    #дать права пользователю
    $ACL = Get-Acl $SrvCatalog
    $setting = "$username", "FullControl", "Allow"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
    $ACL.SetAccessRule($AccessRule)
    $ACL | Set-Acl $SrvCatalog
    $ACL.SetAccessRuleProtection($false, $true)
    #регистрация библиотек
    regsvr32.exe "$comcntrl" -s
    regsvr32.exe $radmin -s
    "installation completed"
    Return
}
#создание ссылок на актуальную версию платформы
function MakeLinks {

    #удалить существующие ссылки
    if (Test-Path -Path "C:\Program Files (x86)\1cv8\current") {
        Remove-Item "C:\Program Files (x86)\1cv8\current" -Recurse -Force -Confirm:$False
    }
        
    if (Test-Path -Path "C:\Program Files\1cv8\current") { 
        Remove-Item "C:\Program Files\1cv8\current" -Recurse -Force -Confirm:$False
    }
        
                  
    "Создать ссылку на последнюю установленную платформу"
    if ( Test-Path -Path "C:\Program Files (x86)\1cv8") {
        "Создать ссылку на последнюю установленную платформу x86"  
        $version = Get-ChildItem -Directory -Path "C:\Program Files (x86)\1cv8\" |Where-Object {$_.Name -like '8.3.*'} | Sort-Object LastWriteTime -Descending |Select-Object -First 1
        $current = 'C:\Program Files (x86)\1cv8\' + $version.Name
        New-Item -ItemType Junction -Path "C:\Program Files (x86)\1cv8\current" -Target $current
        Write-Host 'Создана ссылка на платформу версии' $version.Name 'Путь' $current
                      
    }
       
    if (Test-Path -Path "C:\Program Files\1cv8") {
        "Создать ссылку на последнюю установленную платформу x64"
        $version = Get-ChildItem -Directory -Path "C:\Program Files\1cv8\" |Where-Object {$_.Name -like '8.3.*'} | Sort-Object LastWriteTime -Descending |Select-Object -First 1
        $current = 'C:\Program Files\1cv8\' + $version.Name
        New-Item -ItemType Junction -Path "C:\Program Files\1cv8\current" -Target $current
        Write-Host 'Создана ссылка на платформу версии' $version.Name 'Путь' $current
    }
    Return
}
#установка платформы 1С
function InstallPlatform {
    Clear-Host
    # установка платформы
    $DistrDirectory = 'C:\1cv8.adm'
    # Запрос содержимого папки с дистрибутивами 1С
    $SoftFolder =  Get-ChildItem $DistrDirectory
    # Назначение перемоенной $InstallVersion. Из списка названий папок удаляется всё лишнее, "_" заменяется на ".", оставшееся (8.3.xx.xxxx) передается в переменную $InstallVersion.
    $InstallVersion = $SoftFolder.Name -replace 'windows64full', '' -replace '_8', '8' -replace '_', '.' -replace 'windows64', '' -replace 'windows', '' -replace 'tc', '' | Sort-Object -Descending |Select-Object -First 1 
    # путь к последней папке с дистрибутивом 1С
    $SetupPath = $DistrDirectory + '\' + $InstallVersion #+ '\'
    if (Test-Path -Path $SetupPath) {
        if (Test-Path -Path "$SetupPath\1CEnterprise 8 (x86-64).msi") {
            # Каталог, где находится установочные файлы
            Set-Location $SetupPath;
            $msiInstallerPath = "$SetupPath\1CEnterprise 8 (x86-64).msi"
            $adminstallrelogonPath = "$SetupPath\adminstallrelogon.mst"
            $lang1049Path = "$SetupPath\1049.mst"
            $DESIGNERALLCLIENTS = 1
            $THICKCLIENT = 1
            $THINCLIENTFILE = 1
            $THINCLIENT = 1
            $WEBSERVEREXT = 1
            $SERVER = 1
            $CONFREPOSSERVER = 0
            $CONVERTER77 = 0
            $SERVERCLIENT = 1
            $LANGUAGES = 'RU'
            $params = '/i', 
            $msiInstallerPath,
            # Тихая установка
            '/qn', 
            # Здесь мы подключаем рекомендованную фирмой 1С трансформацию adminstallrelogon.mst и пакет русского языка 1049.mst
            "TRANSFORMS=$adminstallrelogonPath;$lang1049Path", 
            # Это основные компоненты 1С:Предприятия, включая компоненты для администрирования, конфигуратор и толстый клиент. 
            # Без этого параметра ставится всегда только тонкий клиент, независимо от следующего параметра
            "DESIGNERALLCLIENTS=$DESIGNERALLCLIENTS",
            "THICKCLIENT=$THICKCLIENT", # Толстый клиент
            "THINCLIENTFILE=$THINCLIENTFILE", # Тонкий клиент, файловый вариант
            "THINCLIENT=$THINCLIENT", # Тонкий клиент
            "WEBSERVEREXT=$WEBSERVEREXT", # Модули расширения WEB-сервера
            "SERVER=$SERVER", # Сервер 1С:Предприятия
            "CONFREPOSSERVER=$CONFREPOSSERVER", # Сервер хранилища конфигураций
            "CONVERTER77=$CONVERTER77", # Конвертер баз 1С:Предприятия 7.7
            "SERVERCLIENT=$SERVERCLIENT", # Администрирование сервера
            "LANGUAGES=$LANGUAGES" # Язык установки – русский.
             Write-Host "Выполняется установка" -BackgroundColor Black -ForegroundColor Green
            $params
            & msiexec.exe @params | Out-Null
                        
            Return
        }
            #Установка 32-х битной платформы пока не доработана
        <#elseif (Test-Path -Path "$SetupPath\1CEnterprise 8.msi") {
            "x32 сервер устанавливается в тихом режиме, т.к. в другом случае обязательно устанавливается служба сервера 1С"
            # Каталог, где находится установочные файлы
            Set-Location $SetupPath;
            $msiInstallerPath = "$SetupPath\1CEnterprise 8.msi"
            $adminstallrelogonPath = "$SetupPath\adminstallrelogon.mst"
            $lang1049Path = "$SetupPath\1049.mst"        
            $DESIGNERALLCLIENTS = 1
            $THICKCLIENT = 1
            $THINCLIENTFILE = 1
            $THINCLIENT = 1
            $WEBSERVEREXT = 1
            $SERVER = 1
            $CONFREPOSSERVER = 0
            $CONVERTER77 = 0
            $SERVERCLIENT = 1
            $LANGUAGES = 'RU'
            $params = '/i',                 
            $msiInstallerPath,
            # Тихая установка
            '/qn', 
            # Здесь мы подключаем рекомендованную фирмой 1С трансформацию adminstallrelogon.mst и пакет русского языка 1049.mst
            "TRANSFORMS=$adminstallrelogonPath;$lang1049Path", 
            # Это основные компоненты 1С:Предприятия, включая компоненты для администрирования, конфигуратор и толстый клиент.
            # Без этого параметра ставится всегда только тонкий клиент, независимо от следующего параметра
            "DESIGNERALLCLIENTS=$DESIGNERALLCLIENTS",
            "THICKCLIENT=$THICKCLIENT", # Толстый клиент
            "THINCLIENTFILE=$THINCLIENTFILE", # Тонкий клиент, файловый вариант
            "THINCLIENT=$THINCLIENT", # Тонкий клиент
            "WEBSERVEREXT=$WEBSERVEREXT", # Модули расширения WEB-сервера
            "SERVER=$SERVER", # Сервер 1С:Предприятия
            "CONFREPOSSERVER=$CONFREPOSSERVER", # Сервер хранилища конфигураций
            "CONVERTER77=$CONVERTER77", # Конвертер баз 1С:Предприятия 7.7
            "SERVERCLIENT=$SERVERCLIENT", # Администрирование сервера
            "LANGUAGES=$LANGUAGES" # Язык установки – русский.
            Write-Host "Выполняется установка" -BackgroundColor Black -ForegroundColor Green
            $params
            & msiexec.exe @params | Out-Null
            StartMenu
            MakeLinks
        }#>
    }
    Return
}

function FullInstall {
    UserAvailability
    
    
}
# Начало выполнения скрипта
# Информация о сервере
StartInfo
#Запуск стартового меню
StartMenu
