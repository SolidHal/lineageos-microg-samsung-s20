#!/bin/bash


ls -lah /root/userscripts/
patch -p1 < /root/userscripts/AndroidAutoPermissions.patch || echo AA Patch failed!
patch -p1 < /root/userscripts/BraodcastPermissionPatch.patch || echo Broadcast Patch failed!

echo Android Auto Permissions patched!

