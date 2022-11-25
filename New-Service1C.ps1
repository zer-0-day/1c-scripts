﻿#Старт
function StartMenu {
$variant = Read-Host = "Варианты установки
    1. чистая установка 
    2. обновление платформы
    3. чистая установка с IIS"
        if ($variant -eq 1) {
            #Чистая установка, запустить UserAvailability
            UserAvailability
        }   
        elseif ($variant -eq 2) {
            #запуск обновления сервера 
        }  
        elseif ($variant -eq 3) {
            #запуск полной установки с установкой IIS
        }

}
#Функция проверки пользователя
function  UserAvailability ($CheckUser){
$CheckUser = Read-host "Есть ли пользователь?"
if($CheckUser -eq 'Y'){
   #Пользователь существует, перейти к выбору разрядности платформы
    }
elseif($CheckUser -eq 'N'){
   # Пользователя нет, запустить функцию создания пользователя и каталога сервера 
   CreateUser
  }
}
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
            #запуск проверки разрядности платформы
          GetArch      

   } 
function GetArch {
 $Global:arch = Read-Host 'разрядность платформы'
 if ($arch -eq '32') {
    #запуск функции установки службы для x86 платформы
    CreateServicex84
    
 }   
  elseif ($arch -eq '64' ) {
    #запуск функции установки службы для x64 платформы
    CreateServicex64
    
  }  
}
function CreateServicex84 {
  
    $Version = 'Current'
    $username = "USR1CV8"
    $ServiceName = "1C:Enterprise 8.3 Server Agent $Version"
    #Запрос номера порта
    $PortNumber = Read-Host 'Ввести первые две цифры порта сервера 1С'
    #Запрос ввода логина и пароля пользователя USR1CV8                      
    $Mycreds = Get-Credential   
    $RangePort= $PortNumber+'60'+':'+ $PortNumber+'91'
    $BasePort= $PortNumber+'41'
    $CtrlPort=$PortNumber+'40'
    $SrvCatalog= "C:\Program Files (x86)\1cv8\srvinfo"
    $SrvRunCatalog = '"C:\Program Files (x86)\1cv8\srvinfo"'
    $RunPatch = '"C:\Program Files (x86)\1cv8\current\bin\ragent.exe"'
    $DirectoryPath = "C:\Program Files (x86)\1cv8\current\bin\"
    $ServicePath = $RunPatch+ ' ' + '-srvc -agent -regport' +' ' + $BasePort + ' ' +'-port' + ' ' + $CtrlPort+ ' ' + '-range'+' '+ $RangePort+' ' + '-debug -d' +' ' +$SrvRunCatalog
    $comcntrl = $DirectoryPath + 'comcntr.dll'
    $radmin = $DirectoryPath + 'radmin.dll'
    #создать службу
    New-Service -name $ServiceName -binaryPathName $ServicePath -displayName $ServiceName -startupType Automatic -credential $Mycreds
            #дать права пользователю
                $ACL = Get-Acl $SrvCatalog
                $setting = "$username","FullControl","Allow"
                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
                $ACL.SetAccessRule($AccessRule)
                $ACL | Set-Acl $SrvCatalog
                $ACL.SetAccessRuleProtection($false,$true)
                regsvr32.exe "$comcntrl" -s
                regsvr32.exe $radmin -s
"installation completed"
}
function CreateServicex64 {
  
    $Version = 'Current'
    $username = "USR1CV8"
    $ServiceName = "1C:Enterprise 8.3 Server Agent $Version"
    #Запрос номера порта
    $PortNumber = Read-Host 'Ввести первые две цифры порта сервера 1С'
    #Запрос ввода логина и пароля пользователя USR1CV8                      
    $Mycreds = Get-Credential   
    $RangePort= $PortNumber+'60'+':'+ $PortNumber+'91'
    $BasePort= $PortNumber+'41'
    $CtrlPort=$PortNumber+'40'
    $SrvCatalog= "C:\Program Files\1cv8\srvinfo"
    $SrvRunCatalog = '"C:\Program Files (x86)\1cv8\srvinfo"'
    $RunPatch = '"C:\Program Files\1cv8\current\bin\ragent.exe"'
    $DirectoryPath = "C:\Program Files\1cv8\current\bin\"
    $ServicePath = $RunPatch+ ' ' + '-srvc -agent -regport' +' ' + $BasePort + ' ' +'-port' + ' ' + $CtrlPort+ ' ' + '-range'+' '+ $RangePort+' ' + '-debug -d' +' ' +$SrvRunCatalog
    $comcntrl = $DirectoryPath + 'comcntr.dll'
    $radmin = $DirectoryPath + 'radmin.dll'
    #создать службу
    New-Service -name $ServiceName -binaryPathName $ServicePath -displayName $ServiceName -startupType Automatic -credential $Mycreds
            #дать права пользователю
                $ACL = Get-Acl $SrvCatalog
                $setting = "$username","FullControl","Allow"
                $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $setting
                $ACL.SetAccessRule($AccessRule)
                $ACL | Set-Acl $SrvCatalog
                $ACL.SetAccessRuleProtection($false,$true)
                regsvr32.exe "$comcntrl" -s
                regsvr32.exe $radmin -s
"installation completed"
}
function MakeLinks {
    
    
}


                            # Начало выполнения скрипта

    #Запуск стартового меню
    StartMenu
    #Проверка существования пользователя
    UserAvailability
    #проверка разрядности платформы
    GetArch