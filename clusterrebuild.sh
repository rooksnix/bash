#!/bin/bash
lvremove -f fedora/node-01
lvremove -f fedora/node-02
lvremove -f fedora/node-03
sleep 3
lvcreate --size 6G --snapshot --name node-01 /dev/mapper/fedora-rhel6--clustermaster
lvcreate --size 6G --snapshot --name node-02 /dev/mapper/fedora-rhel6--clustermaster
lvcreate --size 6G --snapshot --name node-03 /dev/mapper/fedora-rhel6--clustermaster
