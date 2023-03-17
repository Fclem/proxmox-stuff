#!/bin/bash

#lxc-create <<name>> -t oci -- --url docker://alpine:latest

apt update && apt install skopeo umoci jq -y
target_name="npm" # TODO read
target_rootfs="${lxcpath}/${target}/rootfs"
lxcpath="/root/lxc" # TODO read
target_merged="${lxcpath}/${target}-merged"
target_merged_base_image="${target_merged}/${base_image}"
target_img="jc21/nginx-proxy-manager:latest" # TODO read
base_image="debian-10-standard_10.7-1_amd64.tar.gz" # TODO read

# make lxcpath folder
mkdir -p ${lxcpath} | true
# cd ${lxcpath}
# convert docker image to LCI
lxc-create ${target_name} -t oci --lxcpath ${lxcpath} -- --url docker://${target_img}
# make merged folder
mkdir -p ${target_merged}
# cd ${target_merged}
# copy base image
cp /var/lib/vz/template/cache/${base_image} ${target_merged}/
tar xvf ${target_merged_base_image} ${target_merged}/rootfs/
rm ${target_merged_base_image}
# copy container rootfs over base image
rsync --ignore-existing -a ${lxcpath}/${target}/rootfs/ ${target_merged}/rootfs/
# cp -R ${lxcpath}/${target}/rootfs/. ${target_merged}/rootfs/
cd ${lxcpath}
# compress merged rootfs
tar czvf ${target_name}.tar.gz -C ${target_merged}/rootfs .