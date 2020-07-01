# beeShop
AutoHotkey Script that downloads CIAs from a file, and sends them over to a 3DS using Steveice10's servefiles feature.

## How to use:

NOTE: Make sure your 3DS and the computer you're using beeShop on are on the same network.
NOTE 2: Currently, beeShop only supports downloading & sending one game at a time. (the game.cia file that will be downloaded is rewritten every time you click "Bump")

1. Download & extract the latest beeShop release.
2. Download `db.csv` and put it inside the `assets` folder.
2. On your 3DS, open FBI > Remote Install > "Receive URL's over the Network" and note down the IP of your 3DS (do not close FBI after doing this).
4. Open beeShop.exe, and click on "Settings", which should open a text file called `ip.txt`. Write down your IP (example: `192.168.1.36`) in the first line of it, save the file, and close it.
5. Select a file from the list of the available ones, and click "Bump".

beeShop should now start downloading the game file. Once this is done, click on the "Upload" button and beeShop should now start serving the game file to FBI, which will install it.

## Credits:
* manuGMG,
* Steveice10 ([servefiles.py](https://github.com/Steveice10/FBI/tree/master/servefiles)),
* TimmSkiller (fixes), 
* DexterX12 (fixes),
* Mineplanet84 (testing),
* MyPasswordIsWeak (testing),
* Mike (testing),
* Kaiju (testing).

## Note:
beeShop is not encouraging piracy and it is only a way of gathering homebrew applications to a 3DS modded console.
