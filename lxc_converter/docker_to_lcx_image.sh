#!/bin/bash

# Variables that enable pretty output
RED="\033[31m"
GREEN="\033[32m"
BOLDGREEN="\033[1;32m"
BOLDWHITE="\033[1;37m"
BLUE="\033[0;34m"         # Blue
ENDCOLOR="\033[0;0m"

ENV_SPECS="The environment name can only contain lower case alphanumerical characters, and must be between 3 and 10 characters long"

function runEcho {
    # shellcheck disable=SC2145
    echo -e "${BOLDGREEN}Executing '${ENDCOLOR}${GREEN}${@}${ENDCOLOR}${BOLDGREEN}' ...${ENDCOLOR}"
}

# We log the commands by prefixing them with `run` function
function run {
    # shellcheck disable=SC2145
    runEcho "${@}"

    # shellcheck disable=SC2068
    eval ${@}
}

#lxc-create <<name>> -t oci -- --url docker://alpine:latest

# inputs
target_name="npm" # TODO read
lxcpath="/root/lxc" # TODO read
target_img="jc21/nginx-proxy-manager:latest" # TODO read
base_image="debian-10-standard_10.7-1_amd64.tar.gz" # TODO read
# variables
target_path="${lxcpath}/${target_name}"
target_rootfs="${target_path}/rootfs"
target_merged="${target_path}-merged"
target_merged_rootfs="${target_merged}/rootfs"
target_merged_base_image="${target_merged}/${base_image}"

run apt update && apt install skopeo umoci jq -y && \
# make lxcpath folder
run mkdir -p ${lxcpath} | true
# make merged folder
run mkdir -p ${target_merged} | true
# convert docker image to LCI
run lxc-create ${target_name} -t oci --lxcpath ${lxcpath} -- --url docker://${target_img} && \
# copy base image
run cp /var/lib/vz/template/cache/${base_image} ${target_merged}/ && \  # TODO replace with rsync
run tar xvf ${target_merged_base_image} ${target_merged_rootfs}/ && \
run rm ${target_merged_base_image}
# copy container rootfs over base image
run rsync --ignore-existing -a ${target_rootfs}/ ${target_merged_rootfs}/ && \
run cd ${lxcpath} && \
# compress merged rootfs
run tar czvf ${target_path}.tar.gz -C ${target_merged_rootfs}/ . && \
# move the new image to proper pve folder
run mv ${target_path}.tar.gz /var/lib/vz/template/cache/ && \
# cleanup
run rm -fr ${target_path} ${target_merged} && \
echo -e "${BOLDGREEN}Done.${ENDCOLOR}"
