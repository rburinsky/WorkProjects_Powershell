#Put in destination mac address
$Mac = "00:00:00:00:00:00"
$MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_"}
[Byte[]] $MagicPacket = (,0xFF * 6) + ($MacByteArray  * 16)
$UdpClient = New-Object System.Net.Sockets.UdpClient
#Put in destination ip address
$UdpClient.Connect(([System.Net.IPAddress]::Parse("192.168.1.1")),7)
$UdpClient.Send($MagicPacket,$MagicPacket.Length)
$UdpClient.Close()
