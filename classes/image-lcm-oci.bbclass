#
# This image class creates an oci image spec directory from a generated
# rootfs. The contents of the rootfs do not matter (i.e. they need not be
# container optimized), but by using the container image type and small
# footprint images, we can create directly executable container images.
#
# Once the tarball (or oci image directory) has been created of the OCI
# image, it can be manipulated by standard tools. For example, to create a
# runtime bundle from the oci image, the following can be done:
#
# Assuming the image name is "container-base":
#
#   If the oci image was a tarball, extract it (skip, if a directory is being directly used)
#     % tar xvf container-base-<arch>-<stamp>.rootfs-oci-latest-x86_64-linux.oci-image.tar
#
#   And then create the bundle:
#     % oci-image-tool create --ref name=latest container-base-<arch>-<stamp>.rootfs-oci container-base-oci-bundle
#
#   Alternatively, the bundle can be created with umoci (use --rootless if sudo is not available)
#     % sudo umoci unpack --image container-base-<arch>-<stamp>.rootfs-oci:latest container-base-oci-bundle
#
#   Or to copy (push) the oci image to a docker registry, skopeo can be used (vary the
#   tag based on the created oci image:
#
#     % skopeo copy --dest-creds <username>:<password> oci:container-base-<arch>-<stamp>:latest docker://zeddii/container-base
#
#   If your build host architecture matches the target, you can execute the unbundled
#   container with runc:
#
#     % sudo runc run -b container-base-oci-bundle ctr-build
# / % uname -a
# Linux mrsdalloway 4.18.0-25-generic #26-Ubuntu SMP Mon Jun 24 09:32:08 UTC 2019 x86_64 GNU/Linux
#

# We'd probably get this through the container image typdep, but just
# to be sure, we'll repeat it here.
ROOTFS_BOOTSTRAP_INSTALL = ""
# we want container and tar.bz2's to be created
IMAGE_TYPEDEP:oci = "container tar.bz2"


#OCI_IMAGE_BACKEND ?= "umoci"
do_image_oci[depends] += "umoci-native:do_populate_sysroot"

#
# image type configuration block
#
OCI_IMAGE_AUTHOR ??= "${PATCH_GIT_USER_NAME}"
OCI_IMAGE_AUTHOR_EMAIL ??= "${PATCH_GIT_USER_EMAIL}"

# we assume that IMAGE_VERSION_SUFFIX starts with '-'
OCI_IMAGE_RUNTIME_UID ??= ""

OCI_IMAGE_OS ??= "linux"
OCI_IMAGE_ARCH ??= "${TARGET_ARCH}"
OCI_IMAGE_SUBARCH ??= "${@oci_map_subarch(d.getVar('TARGET_ARCH'), d.getVar('TUNE_FEATURES'), d)}"
OCI_IMAGE_TAG ??= "${@strip_image_version_suffix(d)}"
OCI_IMAGE_STOPSIGNAL ??= "SIGPWR"

OCI_IMAGE_ENTRYPOINT ??= "sh"
OCI_IMAGE_ENTRYPOINT_ARGS ??= ""
OCI_IMAGE_WORKINGDIR ??= "/"

# List of ports to expose from a container running this image:
#  PORT[/PROT]  
#     format: <port>/tcp, <port>/udp, or <port> (same as <port>/tcp).
OCI_IMAGE_PORTS ??= ""

# key=value list of labels
OCI_IMAGE_LABELS ??= ""
# key=value list of environment variables
OCI_IMAGE_ENV_VARS ??= ""

# whether the oci image dir should be left as a directory, or
# bundled into a tarball.
OCI_IMAGE_TAR_OUTPUT ??= "true"
OCI_REUSE_IMAGE ??= "false"

OCI_IMAGE_CUSTOM_ANNOTATIONS ??= ""
OCI_IMAGE_ANNOTATIONS ??= "${@annotation_mount_format(d)} ${OCI_IMAGE_CUSTOM_ANNOTATIONS}"
OCI_IMAGE_ANNOTATION_NAME ??= "${IMAGE_BASENAME}"
OCI_IMAGE_ANNOTATION_DESCRIPTION ??= "${IMAGE_NAME} by ${USER} on ${BUILD_SYS}"
OCI_IMAGE_ANNOTATION_VENDOR ??= "${TARGET_VENDOR}"

def strip_image_version_suffix(d):
    image_version_suffix = d.getVar('IMAGE_VERSION_SUFFIX', True)
    if not image_version_suffix:
        bb.debug(1, "OCI: Cannot get IMAGE_VERSION_SUFFIX, returning latest")
        return "latest"
    if image_version_suffix[0] == '-':
        image_version_suffix = image_version_suffix[1:]
        bb.debug(1, "OCI: Stripping '-' from IMAGE_VERSION_SUFFIX: " + image_version_suffix)
    else:
        bb.debug(1, "OCI: No '-' found so returning IMAGE_VERSION_SUFFIX: " + image_version_suffix)
    return image_version_suffix

def annotation_mount_format(d):
    import json
    mount_annotation_data = { "tr-181": [ ]}
    annotation_var = d.getVar('OCI_IMAGE_ANNOTATION_MOUNTS', True)
    for mount in annotation_var.split(" "):
        if mount == "":
            continue
        bb.debug(1, "Adding: " + mount)
        source, dest = mount.split(':')
        mount_annotation_data["tr-181"].append({"Source": source, "Destination": dest})
    mount_annotation_json = json.dumps(mount_annotation_data).replace(" ", "")
    bb.debug(1, "Generated mount annotation string:\n{0}\n".format(mount_annotation_json))
    return "'org.prplfoundation.mounts={0}'".format(mount_annotation_json).replace(" ", "")

# Generate a subarch that is appropriate to OCI image
# types. This is typically only ARM architectures at the
# moment.
def oci_map_subarch(a, f, d):
    import re
    if re.match('arm.*', a):
        if 'armv8' in f:
            return 'v8'
        elif 'armv7' in f:
            return 'v7'
        elif 'armv6' in f:
            return 'v6'
        elif 'armv5' in f:
            return 'v5'
    return ''

IMAGE_CMD:oci() {
    umoci_options="--no-history"

    bbdebug 1 "UMOCI image settings:"
    bbdebug 1 "  OCI_IMAGE_AUTHOR:                  ${OCI_IMAGE_AUTHOR}"
    bbdebug 1 "  OCI_IMAGE_AUTHOR_EMAIL:            ${OCI_IMAGE_AUTHOR_EMAIL}"
    bbdebug 1 "  OCI_IMAGE_ANNOTATION_NAME:         ${OCI_IMAGE_ANNOTATION_NAME}"
    bbdebug 1 "  OCI_IMAGE_ANNOTATION_VENDOR:       ${OCI_IMAGE_ANNOTATION_VENDOR}"
    bbdebug 1 "  OCI_IMAGE_ANNOTATION_DESCRIPTION:  ${OCI_IMAGE_ANNOTATION_DESCRIPTION}"
    bbdebug 1 "  OCI_IMAGE_TAG:                     ${OCI_IMAGE_TAG}"
    bbdebug 1 "  OCI_IMAGE_ARCH:                    ${OCI_IMAGE_ARCH}"
    bbdebug 1 "  OCI_IMAGE_SUBARCH:                 ${OCI_IMAGE_SUBARCH}"
    bbdebug 1 "  OCI_IMAGE_OS:                      ${OCI_IMAGE_OS}"
    bbdebug 1 "  OCI_IMAGE_ENTRYPOINT:              ${OCI_IMAGE_ENTRYPOINT}"
    bbdebug 1 "  OCI_IMAGE_ENTRYPOINT_ARGS:         ${OCI_IMAGE_ENTRYPOINT_ARGS}"
    bbdebug 1 "  OCI_IMAGE_STOPSIGNAL:              ${OCI_IMAGE_STOPSIGNAL}"
    bbdebug 1 "  OCI_IMAGE_RUNTIME_UID:             ${OCI_IMAGE_RUNTIME_UID}"
    bbdebug 1 "  OCI_IMAGE_WORKINGDIR:              ${OCI_IMAGE_WORKINGDIR}"
    bbdebug 1 "  OCI_IMAGE_ENV_VARS:                ${OCI_IMAGE_ENV_VARS}"
    bbdebug 1 "  OCI_IMAGE_PORTS:                   ${OCI_IMAGE_PORTS}"
    bbdebug 1 "  OCI_IMAGE_LABELS:                  ${OCI_IMAGE_LABELS}"
    bbdebug 1 "  OCI_IMAGE_CUSTOM_ANNOTATIONS:      ${OCI_IMAGE_CUSTOM_ANNOTATIONS}"
    bbdebug 1 "  OCI_IMAGE_ANNOTATIONS:             ${OCI_IMAGE_ANNOTATIONS}"
    bbdebug 1 "  OCI_REUSE_IMAGE:                   ${OCI_REUSE_IMAGE}"
    bbdebug 1 "  IMAGE_BASENAME:                    ${IMAGE_BASENAME}"
    bbdebug 1 "  IMAGE_NAME:                        ${IMAGE_NAME}"
    bbdebug 1 "  IMAGE_NAME_SUFFIX:                 ${IMAGE_NAME_SUFFIX}"
    bbdebug 1 "  IMAGE_LINK_NAME:                   ${IMAGE_LINK_NAME}"
    bbdebug 1 "  IMAGE_VERSION_SUFFIX:              ${IMAGE_VERSION_SUFFIX}"

    # Change into the image deploy dir to avoid having any output operations capture
    # long directories or the location.
    cd "${IMGDEPLOYDIR}"

    if [ -z "${OCI_IMAGE_TAG}" ]; then
        bbdebug 1 "Empty OCI_IMAGE_TAG"
        exit 1
    fi

    oci_image_tag="${OCI_IMAGE_TAG}"
    new_image="true"
    image_name="${IMAGE_NAME}${IMAGE_NAME_SUFFIX}-oci"
    image_bundle_name="${image_name}-bundle"
    if [ "${OCI_REUSE_IMAGE}" == "true" ]; then
        if [ -d "${image_name}" ]; then
            bbdebug 1 "OCI: reusing image directory"
            new_image="false"
        else
            bbdebug 1 "OCI: not cannot reuse image directory, creating new one"
            new_image="true"
        fi
    else
        bbdebug 1 "OCI: removing existing container image directory"
        rm -rf ${image_name} ${image_bundle_name}
    fi

    if [ "${new_image}" == "true" ]; then
        bbdebug 1 "OCI: umoci init --layout ${image_name}"
        umoci init --layout ${image_name}
        bbdebug 1 "OCI: umoci new --image ${image_name}:${oci_image_tag}"
        umoci new --image ${image_name}:${oci_image_tag}
        bbdebug 1 "OCI: umoci unpack --rootless --image ${image_name}:${oci_image_tag} ${image_bundle_name}"
        umoci unpack --rootless --image "${image_name}:${oci_image_tag}" "${image_bundle_name}"
    fi

    bbdebug 1 "OCI: populating rootfs"
    bbdebug 1 "OCI: cp -r ${IMAGE_ROOTFS}/* ${image_bundle_name}/rootfs/"
    # enable dotglob to allow copying hidden files from the root directory
    shopt -s dotglob
    cp -r ${IMAGE_ROOTFS}/* "${image_bundle_name}/rootfs/"
    shopt -u dotglob

    bbdebug 1 "OCI: umoci repack ${umoci_options} --image ${image_name}:${oci_image_tag} ${image_bundle_name}"
    umoci repack ${umoci_options} --image "${image_name}:${oci_image_tag}" "${image_bundle_name}"

    bbdebug 1 "OCI: configuring image"
    if [ -n "${OCI_IMAGE_LABELS}" ]; then
    	for l in ${OCI_IMAGE_LABELS}; do
            bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.label ${l}"
            umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.label "${l}"
    	done
    fi
    if [ -n "${OCI_IMAGE_ENV_VARS}" ]; then
        for l in "${OCI_IMAGE_ENV_VARS}"; do
            bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.env $l"
            umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.env "${l}"
        done
    fi
    if [ -n "${OCI_IMAGE_PORTS}" ]; then
        for l in "${OCI_IMAGE_PORTS}"; do
            bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.exposedports ${l}"
            umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.exposedports "${l}"
        done
    fi
    if [ -n "${OCI_IMAGE_RUNTIME_UID}" ]; then
        bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.user ${OCI_IMAGE_RUNTIME_UID}"
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.user "${OCI_IMAGE_RUNTIME_UID}"
    fi
    if [ -n "${OCI_IMAGE_WORKINGDIR}" ]; then
        bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.workingdir ${OCI_IMAGE_WORKINGDIR}"
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.workingdir "${OCI_IMAGE_WORKINGDIR}"
    fi
    if [ -n "${OCI_IMAGE_OS}" ]; then
        bbdebug 1 "OCI: umoci ${umoci_options} config --image ${image_name}:${oci_image_tag} --os ${OCI_IMAGE_OS}"
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --os "${OCI_IMAGE_OS}"
    fi
    if [ -n "${OCI_IMAGE_STOPSIGNAL}" ]; then
        bbdebug 1 "umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --config.stopsignal ${OCI_IMAGE_STOPSIGNAL}"
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --config.stopsignal "${OCI_IMAGE_STOPSIGNAL}"
    fi
    if [ -n "${OCI_IMAGE_ANNOTATION_NAME}" ]; then
        bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --manifest.annotation \"org.opencontainers.image.ref.name=${OCI_IMAGE_ANNOTATION_NAME}\""
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --manifest.annotation "org.opencontainers.image.ref.name=${OCI_IMAGE_ANNOTATION_NAME}"
    fi
    if [ -n "${OCI_IMAGE_ANNOTATION_VENDOR}" ]; then
        bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --manifest.annotation \"org.opencontainers.image.vendor=${OCI_IMAGE_ANNOTATION_VENDOR}\""
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --manifest.annotation "org.opencontainers.image.vendor=${OCI_IMAGE_ANNOTATION_VENDOR}"
    fi
    if [ -n "${OCI_IMAGE_ANNOTATION_DESCRIPTION}" ]; then
        bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --manifest.annotation \"org.opencontainers.image.description=${OCI_IMAGE_ANNOTATION_VENDOR}\""
        umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --manifest.annotation "org.opencontainers.image.description=${OCI_IMAGE_ANNOTATION_DESCRIPTION}"
    fi
    if [ -n "${OCI_IMAGE_ANNOTATIONS}" ]; then
        for annotation in "${OCI_IMAGE_ANNOTATIONS}"; do
            if [ "${annotation}" != "None" ]; then
                bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --manifest.annotation ${annotation}"
                umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --manifest.annotation "${annotation}"
            fi
        done
    fi

    bbdebug 1 "OCI: umoci config ${umoci_options} --image ${image_name}:${oci_image_tag} --architecture ${OCI_IMAGE_ARCH}"
    umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --architecture "${OCI_IMAGE_ARCH}"
    # NOTE: umoci doesn't currently expose setting the architecture variant,
    #       so if you need it use sloci instead
    if [ -n "${OCI_IMAGE_SUBARCH}" ]; then
        bbnote "OCI: image subarch is set to: ${OCI_IMAGE_SUBARCH}, but umoci does not"
        bbnote "     expose variants. use sloci instead if this is important"
    fi

    umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" \
         ${@" ".join("--config.entrypoint %s" % s for s in d.getVar("OCI_IMAGE_ENTRYPOINT").split())}
    if [ -n "${OCI_IMAGE_ENTRYPOINT_ARGS}" ]; then
        umoci config ${umoci_options} --image $image_name:${OCI_IMAGE_TAG} ${@" ".join("--config.cmd %s" % s for s in d.getVar("OCI_IMAGE_ENTRYPOINT_ARGS").split())}
    fi

    umoci config ${umoci_options} --image "${image_name}:${oci_image_tag}" --author "${OCI_IMAGE_AUTHOR_EMAIL}"

    umoci gc --layout "${image_name}"

    # make a tar version of the image direcotry
    #  1) image_name.tar: compatible with oci tar format, blobs and rootfs
    #     are at the top level. Can load directly from something like podman
    #  2) image_name-dir.tar: original format from meta-virt, is just a tar'd
    #     up oci image directory (compatible with skopeo :dir format)
    if [ -n "${OCI_IMAGE_TAR_OUTPUT}" ]; then
        bbdebug 1 "OCI: Tarring OCI image compatible with oci tar format: ${image_name}.tar"
        (
            cd "${image_name}"
            tar -cf "../${image_name}.tar" "."
        )
        bbdebug 1 "OCI: Tarring OCI image compatible with meta-virt and skopeo dir format: ${image_name}-dir.tar"
        tar -cf "${image_name}-dir.tar" "${image_name}"
        # create a convenience symlink
        bbdebug 1 "OCI: Create convience symlinks for both tar formats: ${image_name}.tar ${image_name}-dir.tar"
        ln -sf "${image_name}.tar" "${IMAGE_BASENAME}-${oci_image_tag}-rootfs-oci.tar"
        ln -sf "${image_name}-dir.tar" "${IMAGE_BASENAME}-${oci_image_tag}-rootfs-oci-dir.tar"
    fi

    # We could make this optional, since the bundle is directly runnable via runc
    bbdebug 1 "OCI: Cleanup ${image_bundle_name}"
    rm -rf "${image_bundle_name}"

    bbdebug 1 "OCI: Create convience symlinks for oci directory that skopeo can upload: ${image_name}"
    ln -sfr "${image_name}" "${IMAGE_LINK_NAME}${IMAGE_NAME_SUFFIX}-oci"
}
