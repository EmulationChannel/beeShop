# beeShop
AutoHotkey Script that downloads CIAs from a database, and sends them over to a 3DS to be installed using Steveice10's servefiles feature.

## How to use:

NOTE: Make sure your 3DS and the computer you're using beeShop on are on the same network, if they aren't, you will not be able to get send the files over to your 3DS.

1. Download & extract the latest beeShop release (preferrably into a separate folder).
2. Download `db.csv` (either made by yourself or from any other source) and put it inside the `assets` folder.
3. On your 3DS, open FBI > Remote Install > "Receive URL's over the Network" and note down the IP of your 3DS (do not close FBI after doing this).
4. Open beeShop.exe, and click on "Settings", which should open a small window that asks you to enter the IP address you noted from step 2. Enter the IP and press OK.
5. Select a game from the list of the available ones, and click "Bump".

beeShop should now start downloading the selected list entry's `.cia` file. Once this is done, click the "Upload" button and beeShop should now ask you to specify the .`cia` file that was downloaded. After you've selected the file, beeShop will start serving the game file to FBI.

Over on your 3DS, you should now see a prompt in FBI asking you if you want to install. Press `Yes`, and FBI will get the file and install it automatically.

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
beeShop does not encourage piracy and is only a way of gathering homebrew applications to a modded Nintendo 3DS System.
