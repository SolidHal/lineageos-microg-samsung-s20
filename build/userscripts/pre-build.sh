#!/bin/bash


ls -lah /root/userscripts/
patch -p0 < /root/userscripts/AndroidAutoPermissions.patch || echo Patch failed!

echo Android Auto Permissions Patched!
