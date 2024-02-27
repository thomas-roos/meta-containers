IMAGE_MANIFEST_ROOTFS_ENABLE ??= "y"
IMAGE_MANIFEST_ROOTFS_LOCATION ??= "/components.txt"
IMAGE_MANIFEST_GREP_MANIFEST ??= ".rootfs.manifest"

fakeroot do_copy_manifest_to_image() {
    # Copy the file to the root directory of the image
    if [[ "${IMAGE_MANIFEST_ROOTFS_ENABLE}" == "y" ]]; then
        echo "Trying to copy image manifest to rootfs:"
        if [ -f ${IMAGE_MANIFEST} ]; then
            echo "\t${IMAGE_MANIFEST} -> ${IMAGE_ROOTFS}/${IMAGE_MANIFEST_ROOTFS_LOCATION}"
            install -o root -g root -D -m 0644 ${IMAGE_MANIFEST} ${IMAGE_ROOTFS}/${IMAGE_MANIFEST_ROOTFS_LOCATION}
        else
            DEPLOY_DIR_IMAGE_GUESSED=$(dirname ${IMAGE_MANIFEST})
            IMAGE_MANIFEST_GUESSED=$(ls -Art ${DEPLOY_DIR_IMAGE_GUESSED} | grep ${IMAGE_MANIFEST_GREP_MANIFEST} | tail -n 1)
            if [ ! -z "${IMAGE_MANIFEST_GUESSED}" ] && [ -f "${DEPLOY_DIR_IMAGE_GUESSED}/${IMAGE_MANIFEST_GUESSED}" ]; then
                echo "\tGuessed manifest correctly:"
                echo "\t${DEPLOY_DIR_IMAGE_GUESSED}/${IMAGE_MANIFEST_GUESSED} -> ${IMAGE_ROOTFS}/${IMAGE_MANIFEST_ROOTFS_LOCATION}"
                install -o root -g root -D -m 0644 ${DEPLOY_DIR_IMAGE_GUESSED}/${IMAGE_MANIFEST_GUESSED} ${IMAGE_ROOTFS}/${IMAGE_MANIFEST_ROOTFS_LOCATION}
            else
                echo "\t!! Cannot get manifest !!"
                exit 1
            fi
        fi
    else
        echo "Not copying image manifest to rootfs!"
    fi

    exit 0
}

addtask copy_manifest_to_image after do_rootfs before do_image do_image_oci do_rootfs_wicenv do_image_tar do_image_debugfs_tar
