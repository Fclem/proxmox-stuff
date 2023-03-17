#!/bin/bash

#lxc-create <<name>> -t oci -- --url docker://alpine:latest

apt update && apt install skopeo umoci jq -y
target_name="npm" # TODO read
target_rootfs="${lxcpath}/${target_name}/rootfs"
lxcpath="/root/lxc" # TODO read
target_merged="${lxcpath}/${target_name}-merged"
target_merged_rootfs="${target_merged}/rootfs"
target_merged_base_image="${target_merged}/${base_image}"
target_img="jc21/nginx-proxy-manager:latest" # TODO read
base_image="debian-10-standard_10.7-1_amd64.tar.gz" # TODO read

# make lxcpath folder
mkdir -p ${lxcpath} | true
# make merged folder
mkdir -p ${target_merged} | true
# convert docker image to LCI
lxc-create ${target_name} -t oci --lxcpath ${lxcpath} -- --url docker://${target_img} && \
# copy base image
cp /var/lib/vz/template/cache/${base_image} ${target_merged}/ && \ # TODO replace with rsync
tar xvf ${target_merged_base_image} ${target_merged_rootfs}/ && \
rm ${target_merged_base_image}
# copy container rootfs over base image
rsync --ignore-existing -a ${target_rootfs}/ ${target_merged_rootfs}/ && \
cd ${lxcpath} && \
# compress merged rootfs
tar czvf ${target_name}.tar.gz -C ${target_merged_rootfs}/ .
