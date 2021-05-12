#!/bin/bash


patch -p0 /root/userscripts/AndroidAutoPermissions.patch || echo Patch failed!

echo Android Auto Permissions Patched!
