
$DistrDirectory = 'C:\1cv8.adm'
$username = "USR1CV8"

# Стартовое меню
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
    Write-Host "4. Создать ссылку на папку с дистрибутивами 1С" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "5. Обновление PowerShell" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "6. Частичная установка сервера 1С " -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "q. Exit" -ForegroundColor Green
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host
    

       while($true)
    {
    $choice = Read-Host "Select the menu item: "
    
    Switch($choice){
    1{FullInstall}
    2{InstallPlatform}
    3{MakeLinks}
    4{1CDistrFolder}
    5{UpdatePowershell}
    6{PartialInstall}
    q{Write-Host "q"; return}
    default {Write-Host "Wrong choice, try again." -ForegroundColor Red}
    }
    }
      
}
# Сбор информации при старте скрипта        
function StartInfo {
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 Write-host "Скрипт автоматизации ручных задач установки и обновления сервера 1С. v 1.0" -BackgroundColor Black -ForegroundColor Green
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 Write-host "Запрос и сортировка версий 1С" -BackgroundColor Black -ForegroundColor Green
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 $install1CVersion = Get-Package | Where-Object {$_.Name -match "^(1С|1C)"} 
 $ListVersion =  $install1CVersion.version #$install1CVersion.Name -replace '1С:Предприятие 8' , ''  -replace 'Тонкий клиент', '' -replace '[(]' , '' -replace '[)]' , '' -replace 'x86-64' , '' -replace ' ' , '' 
 Write-Host "Все установленные платформы 1С: " -BackgroundColor Black -ForegroundColor Green
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 $ListVersion |Sort-Object -Descending
 $LastVersion = $ListVersion |Sort-Object -Descending |Select-Object -First 1
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
 Write-Host "Последняя установленная версия платформы 1С:" -BackgroundColor Black -ForegroundColor Green
 $LastVersion
 Write-Host "-----------------------------------------------" -ForegroundColor Blue
# Проверка существования только одной версии файла ragent.exe 
# Проверка существования ссылки Current.
 if (Test-Path -Path "C:\Program Files\1cv8\current\ragent.exe") {
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
 
# Проверка пути установки платформы
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
# Запрос версии сервера 1С
            if (Select-String file -Pattern 'Current') {
                if (Test-Path -Path "C:\Program Files\1cv8\current\bin"){
                    Write-Host "Версия x64 сервера current" -BackgroundColor Black -ForegroundColor Green 
                    Write-Host (Get-Item "C:\Program Files\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
                    }
                if (Test-Path -Path "C:\Program Files\1cv8 (x86)\current\bin"){
                    Write-Host "Версия x86 сервера current" -BackgroundColor Black -ForegroundColor Green
                    Write-Host (Get-Item "C:\Program Files (x86)\1cv8\current\bin\ragent.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
                    }
            }
            else {
            Write-Host "-----------------------------------------------" -ForegroundColor Blue
            Write-Host 'Служба сервера с ссылкой "Current" не найдена' -BackgroundColor Black -ForegroundColor Green
            }
            Remove-Item file

# Проверка существования ссылок Current и вывод версии платформы 1С, на которую созданы ссылки.
                         
                if (Test-Path -Path "C:\Program Files\1cv8\current\bin"){
                    Write-Host "-----------------------------------------------" -ForegroundColor Blue
                    Write-Host 'Ссылка x64 "Current" существует. Версия 1С Предприятие:' -BackgroundColor Black -ForegroundColor Green 
                    Write-Host (Get-Item "C:\Program Files\1cv8\current\bin\1cv8.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
                    }
                    else {
                        Write-Host "-----------------------------------------------" -ForegroundColor Blue
                        Write-Host 'Ссылка x64 "Current" не найдена' -BackgroundColor Black -ForegroundColor Green
                        }
                if (Test-Path -Path "C:\Program Files\1cv8 (x86)\current\bin"){
                    Write-Host "-----------------------------------------------" -ForegroundColor Blue
                    Write-Host 'Ссылка x86 "Current" существует. Версия 1С Предприятие:' -BackgroundColor Black -ForegroundColor Green
                    Write-Host (Get-Item "C:\Program Files (x86)\1cv8\current\bin\1cv8.exe").VersionInfo.ProductVersion -BackgroundColor Black -ForegroundColor White
                    }
                    else {
                        Write-Host "-----------------------------------------------" -ForegroundColor Blue
                        Write-Host 'Ссылка x86 "Current" не найдена' -BackgroundColor Black -ForegroundColor Green
                        }
# Проверка наличия линка на директорию с дистрибутивами
# Поиск папки с дистрибутивами
if (Test-Path 'C:\1cv8.adm') {
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "Есть линк на директорию с дистрибутивами 1C"
    # Переименование папок 1С
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace 'windows64full_', ''} -erroraction 'silentlycontinue'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace '_', '.'} -erroraction 'silentlycontinue'
}
elseif (Test-Path 'D:\1cv8.adm') {
        New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target 'D:\1cv8.adm'
    Write-Host "-----------------------------------------------" -ForegroundColor Blue    
    Write-Host "Директория с дистрибутивами 1С находится на диске D"
    # Переименование папок 1С
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace 'windows64full_', ''} -erroraction 'silentlycontinue'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace '_', '.'} -erroraction 'silentlycontinue'
}
elseif (Test-Path 'E:\1cv8.adm') {
        New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target 'E:\1cv8.adm'
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-host "Директория с дистрибутивами 1С находится на диске E"
    # Переименование папок 1С
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace 'windows64full_', ''} -erroraction 'silentlycontinue'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace '_', '.'} -erroraction 'silentlycontinue'
}

elseif ($GetPath = Write-Host 'Директория с дистрибутивами 1С не найдена! Вернитесь в стартовое меню и создайте ссылку на папку с дистрибутивами 1С' -BackgroundColor Black -ForegroundColor Red  ) {

}

# Проверка версии Powershell
if ($PSVersionTable.PSVersion.Major -lt 5 ) {
    Write-Host "-----------------------------------------------" -ForegroundColor Blue
    Write-Host "Версия Powershell ниже рекомендуемой. Дальнейшая работа невозможна. Обновите Powershell при помощи соответствующего пункта меню (потребуется перезапуск сервера)" -BackgroundColor Black -ForegroundColor Red
}
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
    StartMenu
}
#установка платформы 1С
function InstallPlatform {
    Clear-Host
    # Поиск папки с дистрибутивами
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
    # установка платформы
    $DirectoryPath = "C:\Program Files\1cv8\current\bin\"
    $comcntrl = $DirectoryPath + 'comcntr.dll'
    $radmin = $DirectoryPath + 'radmin.dll'
    $SoftFolder =  Get-ChildItem $DistrDirectory | Where-Object {$_.Name -match "^(8_3|8.3)"} # Запрос содержимого папки с дистрибутивами 1С
    # Назначение переменной $InstallVersion. Из списка названий папок удаляется всё лишнее, "_" заменяется на ".", оставшееся (8.3.xx.xxxx) передается в переменную $InstallVersion.
    $InstallVersion = $SoftFolder  -replace 'windows64full_', '' -replace '_', '.' | Sort-Object -Descending |Select-Object -First 1
    # Переименование папок с дистрибутивами 1С. Переименовываются только папки содержащие полный 64 битный установщик сервера 1С
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace 'windows64full_', ''} -erroraction 'silentlycontinue'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace '_', '.'} -erroraction 'silentlycontinue'
    # Путь к последней папке с дистрибутивом 1С
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
             Write-Host "Выполняется установка. Ожидайте" -BackgroundColor Black -ForegroundColor Green
            $params
            & msiexec.exe @params | Out-Null
            # Регистрация библиотек
            regsvr32.exe "$comcntrl" -s
            Write-Host 'Библиотека comcntrl зарегистрирована' -BackgroundColor Black -ForegroundColor Green
            regsvr32.exe $radmin -s
            Write-Host 'Библиотека radmin зарегистрирована' -BackgroundColor Black -ForegroundColor Green
            MakeLinks          
            Return
        }
           
    }
    StartMenu
}

function FullInstall {
    if (Get-Item "C:\Program Files\1cv8\current\bin\ragent.exe" -ErrorAction 'silentlycontinue') {

        Write-Host 'Существует ссылка "Current". Дальнейшая установка невозможна. Запустите пункт обновления платформы или удалите ссылки и службу current'
        StartMenu
    }
               #УСТАНОВКА СЕРВЕРА 1С
   # Проверка существования линка на папку с дистрибутивами 1С
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
    elseif ( Write-Host 'Директория с дистрибутивами 1С не найдена! Вернитесь в стартовое меню и создайте ссылку на папку с дистрибутивами 1С' -BackgroundColor Black -ForegroundColor Red  ) {
    }     
    if (Test-Path -Path $DistrDirectory -ErrorAction 'silentlycontinue') {
        
    
    if (!(Get-LocalUser |Where-Object {$_.Name -match "USR1CV8"})) {
             
  # СОЗДАТЬ ПОЛЬЗОВАТЕЛЯ
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
                   

   
  
  # Запрос содержимого папки с дистрибутивами 1С
  $SoftFolder =  Get-ChildItem $DistrDirectory | Where-Object {$_.Name -match "^(8_3|8.3)"}
  # Назначение переменной $InstallVersion. Из списка названий папок удаляется всё лишнее, "_" заменяется на ".", оставшееся (8.3.xx.xxxx) передается в переменную $InstallVersion.
  $InstallVersion = $SoftFolder  -replace 'windows64full_', '' -replace '_', '.' | Sort-Object -Descending |Select-Object -First 1
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
           Write-Host "Выполняется установка. Ожидайте" -BackgroundColor Black -ForegroundColor Green
          $params
          & msiexec.exe @params | Out-Null
            #Создать службу и каталог сервера
   

                $Version = 'Current'
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
                # Создать каталог сервера и дать права пользователю

                if (!(Test-Path -Path $SrvCatalog)) {
                        <# Action to perform if the condition is true #>
                        New-Item $SrvCatalog -ItemType Directory
                    }
                $ACL = Get-Acl $SrvCatalog
                $setting = "$username", "FullControl", "Allow"
                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
                $ACL.SetAccessRule($AccessRule)
                $ACL | Set-Acl $SrvCatalog
                $ACL.SetAccessRuleProtection($false, $true)
                #регистрация библиотек
                regsvr32.exe "$comcntrl" -s
                Write-Host 'Библиотека comcntrl зарегистрирована' -BackgroundColor Black -ForegroundColor Green
                regsvr32.exe $radmin -s
                Write-Host 'Библиотека radmin зарегистрирована' -BackgroundColor Black -ForegroundColor Green
                Start-Service "1C:Enterprise 8.3 Server Agent Current"
                Write-Host "Статус службы сервера 1С"
                Get-Service "1C:Enterprise 8.3 Server Agent Current" |Where-Object Status |Select-Object Status

                " Service installation completed"

      }




          #СОЗДАТЬ ССЫЛКИ CURRENT
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


    }
}
}
StartMenu
function 1CDistrFolder {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Data Entry Form'
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,120)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,120)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Please enter the information in the space below:'
    $form.Controls.Add($label)
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,40)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($textBox)
    $form.Topmost = $true
    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $GetPath = $textBox.Text
    }
    New-Item -ItemType Junction -Path "C:\1cv8.adm\" -Target $GetPath 
    $DistrDirectory = 'C:\1cv8.adm'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace 'windows64full_', ''} -erroraction 'silentlycontinue'
    Get-ChildItem  $DistrDirectory  | Rename-Item -NewName {$_.Name -replace '_', '.'} -erroraction 'silentlycontinue'
    StartMenu
}

#Обновление PowerShell
function UpdatePowerShell {
    $Psversion = $PSVersionTable.PSVersion |Where-Object Major|Select-Object Major
if (Test-Path -Path "C:\ProgramData\chocolatey") {
    $ChocoVersion =  (Get-Item "C:\ProgramData\chocolatey\choco.exe").VersionInfo.ProductVersion
    Write-Host 'Версия Chocolatey' $ChocoVersion 
    Write-Host 'Обновление Powershell'
    choco.exe install powershell -y 
    Write-Host 'Для завершения обновления требуется перезагрузка' 
  
}
else {
   Write-Host 'Установка Chocolatey' 
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-Null
   choco.exe install powershell -y
       if((Get-Item "C:\ProgramData\chocolatey\choco.exe" -erroraction 'silentlycontinue').VersionInfo.ProductVersion){
           $ChocoVersion = (Get-Item "C:\ProgramData\chocolatey\choco.exe" -erroraction 'silentlycontinue').VersionInfo.ProductVersion
          Write-Host 'Установка завершена. Версия Chocolatey' $ChocoVersion 
          Write-Host 'Обновление Powershell'
          choco.exe install powershell -y 
          Write-Host 'Для завершения обновления требуется перезагрузка' 
       }
       else {
       Write-Host 'Установка не выполнена' 
       }
}
    
}
StartMenu
# Частичная установка сервера 1С. Устанавливается служба, создаются ссылки.
function PartialInstall{
  # Проверка существования линка на папку с дистрибутивами 1С
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
    elseif ( Write-Host 'Директория с дистрибутивами 1С не найдена! Вернитесь в стартовое меню и создайте ссылку на папку с дистрибутивами 1С' -BackgroundColor Black -ForegroundColor Red  ) {
    }

        # Запрос содержимого папки с дистрибутивами 1С
        $SoftFolder =  Get-ChildItem $DistrDirectory | Where-Object {$_.Name -match "^(8_3|8.3)"}
        # Назначение переменной $InstallVersion. Из списка названий папок удаляется всё лишнее, "_" заменяется на ".", оставшееся (8.3.xx.xxxx) передается в переменную $InstallVersion.
        $InstallVersion = $SoftFolder  -replace 'windows64full_', '' -replace '_', '.' | Sort-Object -Descending |Select-Object -First 1
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
            Write-Host "Выполняется установка. Ожидайте" -BackgroundColor Black -ForegroundColor Green
            $params
            & msiexec.exe @params | Out-Null

                            #СОЗДАТЬ ССЫЛКИ CURRENT
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
                    #Создать службу и каталог сервера
                        $Version = 'Current'
                        $ServiceName = "1C:Enterprise 8.3 Server Agent $Version"
                        #Запрос номера порта
                        Add-Type -AssemblyName System.Windows.Forms
                        Add-Type -AssemblyName System.Drawing
                        $form = New-Object System.Windows.Forms.Form
                        $form.Text = 'Номер порта сервера'
                        $form.Size = New-Object System.Drawing.Size(300,200)
                        $form.StartPosition = 'CenterScreen'
                        $okButton = New-Object System.Windows.Forms.Button
                        $okButton.Location = New-Object System.Drawing.Point(75,120)
                        $okButton.Size = New-Object System.Drawing.Size(75,23)
                        $okButton.Text = 'OK'
                        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                        $form.AcceptButton = $okButton
                        $form.Controls.Add($okButton)
                        $cancelButton = New-Object System.Windows.Forms.Button
                        $cancelButton.Location = New-Object System.Drawing.Point(150,120)
                        $cancelButton.Size = New-Object System.Drawing.Size(75,23)
                        $cancelButton.Text = 'Cancel'
                        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                        $form.CancelButton = $cancelButton
                        $form.Controls.Add($cancelButton)
                        $label = New-Object System.Windows.Forms.Label
                        $label.Location = New-Object System.Drawing.Point(10,20)
                        $label.Size = New-Object System.Drawing.Size(280,27)
                        $label.Text = 'Введите первые две цифры номера порта (по умолчанию 15, если установлен 1 сервер):'
                        $form.Controls.Add($label)
                        $textBox = New-Object System.Windows.Forms.TextBox
                        $textBox.Location = New-Object System.Drawing.Point(10,55)
                        $textBox.Size = New-Object System.Drawing.Size(260,40)
                        $form.Controls.Add($textBox)
                        $form.Topmost = $true
                        $form.Add_Shown({$textBox.Select()})
                        $result = $form.ShowDialog()
                        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                        {
                            $PortNumber = $textBox.Text
                        }
                        #Запрос ввода логина и пароля пользователя USR1CV8                      
                        $Mycreds = Get-Credential   
                        $RangePort = $PortNumber + '60' + ':' + $PortNumber + '91'
                        $BasePort = $PortNumber + '41'
                        $CtrlPort = $PortNumber + '40'
                        Add-Type -AssemblyName System.Windows.Forms
                        Add-Type -AssemblyName System.Drawing
                        $form = New-Object System.Windows.Forms.Form
                        $form.Text = 'Путь к каталогу сервера 1С'
                        $form.Size = New-Object System.Drawing.Size(300,200)
                        $form.StartPosition = 'CenterScreen'
                        $okButton = New-Object System.Windows.Forms.Button
                        $okButton.Location = New-Object System.Drawing.Point(75,120)
                        $okButton.Size = New-Object System.Drawing.Size(75,23)
                        $okButton.Text = 'OK'
                        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
                        $form.AcceptButton = $okButton
                        $form.Controls.Add($okButton)
                        $cancelButton = New-Object System.Windows.Forms.Button
                        $cancelButton.Location = New-Object System.Drawing.Point(150,120)
                        $cancelButton.Size = New-Object System.Drawing.Size(75,23)
                        $cancelButton.Text = 'Cancel'
                        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                        $form.CancelButton = $cancelButton
                        $form.Controls.Add($cancelButton)
                        $label = New-Object System.Windows.Forms.Label
                        $label.Location = New-Object System.Drawing.Point(10,20)
                        $label.Size = New-Object System.Drawing.Size(280,20)
                        $label.Text = 'Путь к каталогу SrvInfo:'
                        $form.Controls.Add($label)
                        $textBox = New-Object System.Windows.Forms.TextBox
                        $textBox.Location = New-Object System.Drawing.Point(10,40)
                        $textBox.Size = New-Object System.Drawing.Size(260,20)
                        $form.Controls.Add($textBox)
                        $form.Topmost = $true
                        $form.Add_Shown({$textBox.Select()})
                        $result = $form.ShowDialog()
                        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
                        {
                            $GetSrvCatalog = $textBox.Text
                        }
                        
                        $SrvCatalog =  $GetSrvCatalog
                        $ACL = Get-Acl $SrvCatalog 
                        $setting = "$username", "FullControl", "Allow"
                        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
                        $ACL.SetAccessRule($AccessRule)
                        $ACL | Set-Acl $SrvCatalog
                        $ACL.SetAccessRuleProtection($false, $true)
                        $RunPath = '"C:\Program Files\1cv8\current\bin\ragent.exe"'
                        $DirectoryPath = "C:\Program Files\1cv8\current\bin\"
                        $ServicePath = $RunPath + ' ' + '-srvc -agent -regport' + ' ' + $BasePort + ' ' + '-port' + ' ' + $CtrlPort + ' ' + '-range' + ' ' + $RangePort + ' ' + '-debug -d' + ' ' + $SrvCatalog
                        $comcntrl = $DirectoryPath + 'comcntr.dll'
                        $radmin = $DirectoryPath + 'radmin.dll'
                        #создать службу
                        New-Service -name $ServiceName -binaryPathName $ServicePath -displayName $ServiceName -startupType Automatic -credential $Mycreds    

    }
                            regsvr32.exe "$comcntrl" -s
                            Write-Host 'Библиотека comcntrl зарегистрирована' -BackgroundColor Black -ForegroundColor Green
                            regsvr32.exe $radmin -s
                            Write-Host 'Библиотека radmin зарегистрирована' -BackgroundColor Black -ForegroundColor Green
}
}
StartMenu

# Информация о сервере
StartInfo
#Запуск стартового меню
StartMenu
