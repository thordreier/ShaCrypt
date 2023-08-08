function Convert-ByteArrayToMappedBase64 ($ByteArray, $OrderMap,$CharMap)
{
    ($OrderMap | ForEach-Object -Process {
        $ba = @($_ | ForEach-Object -Process {$ByteArray[$_]})
        $ba += @(0) * (4 - $ba.Length)
        $int = [System.BitConverter]::ToUInt32($ba, 0)
        0..($_.Length) | ForEach-Object -Process {
            $CharMap[$int -band 63]
            $int = $int -shr 6
        }
    }) -join ''
}
