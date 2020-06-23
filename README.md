# beeShop
AutoHotkey Script that downloads 3DS game files from a database, and copies them over to a 3DS via FTP.

How to use:

1. Download & Extract the latest beeShop release.
2. Open an FTP Client (like [ftpd](https://github.com/mtheall/ftpd)) on your 3DS and note down the IP and Port
3. Open beeShop.exe, and click on "IP Config" which should open a text file, replace `IP:Port` with your noted IP and Port (example: `192.168.1.36`), save the file, and close it
4. Select game from the list of the available ones, and click "Bump"

beeShop should now start downloading the game file, once this is done, it will start coping the file via FTP to your 3DS's SD Card root. Once this is done, you can install it like you would normally with any other CIA using FBI.
