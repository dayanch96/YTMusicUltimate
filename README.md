# YTMusicUltimate
<p align="center">
<img src=https://user-images.githubusercontent.com/38832025/235781424-06d81647-b3db-4d9b-94dc-cd65cdf09145.png?raw=true) />
</p>    

<p align="center">
<img src=https://user-images.githubusercontent.com/38832025/235781207-6d1ad44e-0c32-4aec-9c75-cb928ca8a0d3.png?raw=true) />
</p>

<p align="center">
The best tweak for the YouTube Music on iOS.
</p>

## Download Links

* **Jailbreak:**
Add __[https://ginsu.dev/repo](https://ginsu.dev/repo)__ to your favorite installer and download latest version from there, or from __[Releases](https://github.com/ginsudev/YTMusicUltimate/releases)__ page.

(arm.deb version for Rootful and arm64.deb version for Rootless devices)

* **Sideloading:**
  We no longer provide a sideloading IPA but you can build one yourself, keep reading:

## How to build a YTMusicUltimate IPA by yourself using Github actions

1. Fork this repository using the fork button on the top right.
2. On your forked repository, go to Repository Settings > Actions, enable Read and Write permissions.
3. Go to the Actions tab on your forked repo, click on "Build and Release YTMusicUltimate" located on the left side. Click "Run workflow" button located on the right side.
4. Provide a URL for a decrypted YTMusic IPA. ***ANY OTHER EXTENSION WON'T WORK, find a decrypted .IPA and upload into a file provider i.e DROPBOX***
5. Click "Run workflow" again. You can download the tweaked IPA from the releases section of your repo after the build finishes. (**Go to your forked repo and add /releases to the url i.e https://github.com/YOURUSERNAME/YTMusicUltimate/releases**)

## IPA building troubleshooting(I can't build the IPA/Github action fails/I can't find the releases section etc.)

99.9% of the time, the culprit is the IPA URL you provided. You HAVE TO provide a decryped IPA. It cannot be any other extension, it has to be a **.ipa**. Find the decrypted IPA(no we can't help you, use your googling skills or give up), upload it to Dropbox, give the URL to the github action. It'll work, pinky promise.

If the github action works and you cannot find the final ipa, you need to add /releases to the url of your forked repository. Its probably something like this: https://github.com/YOURUSERNAME/YTMusicUltimate/releases replace the YOURUSERNAME part with your username. It may seem invisible but if the github action is successful, ipa is there.


## How to build the package by yourself on your device
1. Install __[Theos](https://theos.dev/docs/installation)__
2. Clone this repo __[using git](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)__
3. Cd your YTMusicUltimate folder and run:

   • '**make clean package**' to build deb for rootful device
   
   • '**make clean package ROOTLESS=1**' to build deb for rootless device
   
   • '**make clean package SIDELOADING=1**' to build deb for injecting in to ipa
   
   

   • To learn how to inject tweaks in to ipa visit __[here (Azule)](https://github.com/Al4ise/Azule)__




Made with ❤ by Ginsu and Dayanch96
