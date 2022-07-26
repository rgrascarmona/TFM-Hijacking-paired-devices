#
# Este script se usa para extraer las claves de cifrado de los dispositivos Bluetooth y BLE emparejados a un equipo Windows
# 
# Autor: Ramón Gras Carmona
#

$btAdapters = Get-Item -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Keys\*

foreach ($btAdapter in $btAdapters)
{
    $adaptador = $btAdapter.ToString().split("\")[-1]
    Write-Output "Claves del controlador:$adaptador"
    Write-Output "-------------------------------------`n"
    
    # Bluetooth 
    $devices_old = $btAdapter.Property | Where-Object {$_ -ne "MasterIRK"}
    Write-Output "`rDispositivos Bluetooth:`r`n"

    if ($devices_old){
    
    foreach ($btDeviceMac in $devices_old)
    {
        $btDeviceKey = $btAdapter.GetValue($btDeviceMac)
        Write-Output "MAC: $btDeviceMac KEY: $(($btDeviceKey|ForEach-Object ToString X2) -join '')"
    }
    }
    else
    {
    Write-Output "No se han encontrado dispositivos!!!`n"
    }

    # BLE
    $devices = $btAdapter.GetSubKeyNames()
       
    Write-Output "`r`nDispositivos BLE:`r`n"

    if ($devices){

    foreach ($btDeviceRegKey in $devices)
    {
        Write-Output "MAC   : $btDeviceRegKey".ToUpper() 
        $btDeviceSubKey = $btAdapter.OpenSubKey($btDeviceRegKey)

        # LTK
        $btLTK = $btDeviceSubKey.GetValue("LTK")
        if ($btLTK)
        {
            Write-Output "LTK   : $(($btLTK|ForEach-Object ToString X2) -join '')"
        }
                
        $btERand = $btDeviceSubKey.GetValue("ERand")
        if ($btERand)
        {
            $btERandBytes = [bitconverter]::GetBytes($btERand)
            $btERandNumber = [bitconverter]::ToUInt64($btERandBytes, 0)
            Write-Output "ERand : $btERandNumber"
            [array]::Reverse($btERandBytes)
            $btERandNumber = [bitconverter]::ToUInt64($btERandBytes, 0)
            Write-Output "ERand : $btERandNumber (Con el orden invertido. Si el anterior no funciona, prueba con este)"
        }
        
        # EDIV
        $btEDIV = $btDeviceSubKey.GetValue("EDIV")
        if ($btEDIV)
        {
            Write-Output "EDIV  : $btEDIV"
        }
        
        # IRK
        $btIRK = $btDeviceSubKey.GetValue("IRK")
        if ($btIRK)
        {
            Write-Output "IRK   : $(($btIRK|ForEach-Object ToString X2) -join '')"          
        }
        
        # CSRK
        $btCSRK = $btDeviceSubKey.GetValue("CSRK")
        if ($btCSRK)
        {
            Write-Output "CSRK  : $(($btCSRK|ForEach-Object ToString X2) -join '')"
            
        }
        else
        {
            Write-Output "CSRK  : No se ha encontrado ninguna clave para el dispositivo"
            
        }
        
        Write-Output ""
        
    }
    } 
    else
    {
     Write-Output "No se han encontrado dispositivos!!!`n"
    }
}
