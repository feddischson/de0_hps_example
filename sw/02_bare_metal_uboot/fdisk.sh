#!/bin/bash

(
echo n
echo p
echo 2
echo 2048
echo +1M
echo n
echo p
echo 1
echo 4096
echo +5M
echo t
echo 2
echo a2
echo t
echo 1
echo c
echo w
echo q
) | /sbin/fdisk $1
