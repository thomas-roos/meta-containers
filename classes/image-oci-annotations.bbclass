
do_image_oci[depends] += "annoci-native:do_populate_sysroot"

OCI_IMAGE_ANNOTATIONS ??= ""
OCI_IMAGE_ANNOTATION_MOUNTS ??= ""
OCI_IMAGE_ANNOTATION_NAME ??= ""
OCI_IMAGE_ANNOTATION_VENDOR ??= ""
OCI_IMAGE_ANNOTATION_VERSION ??= ""


IMAGE_CMD:oci:append() {
    bbdebug 1 "ANNOCI image settings:"
    bbdebug 1 "  annotations: ${OCI_IMAGE_ANNOTATIONS}"
    bbdebug 1 "  mounts: ${OCI_IMAGE_ANNOTATION_MOUNTS}"
    bbdebug 1 "  name: ${OCI_IMAGE_ANNOTATION_NAME}"
    bbdebug 1 "  vendor: ${OCI_IMAGE_ANNOTATION_VENDOR}"
    bbdebug 1 "  version ${OCI_IMAGE_ANNOTATION_VERSION}"

    # Parse args and change them in arguments that annoci can use
    annotations_arg=""
    if [ -n "${OCI_IMAGE_ANNOTATIONS}" ]; then
    for a in ${OCI_IMAGE_ANNOTATIONS}; do
        annotations_arg="${annotations_arg} --anno-image-manifest ${a}"
    done
    fi

    mounts_arg=""
    if [ -n "${OCI_IMAGE_ANNOTATION_MOUNTS}" ]; then
    for m in ${OCI_IMAGE_ANNOTATION_MOUNTS}; do
        mounts_arg="${mounts_arg} --mount ${m}"
    done
    fi

    name_arg=""
    if [ -n "${OCI_IMAGE_ANNOTATION_NAME}" ]; then
        name_arg="--name ${OCI_IMAGE_ANNOTATION_NAME}"
    fi

    vendor_arg=""
    if [ -n "${OCI_IMAGE_ANNOTATION_VENDOR}" ]; then
        vendor_arg="--vendor ${OCI_IMAGE_ANNOTATION_VENDOR}"
    fi

    version_arg=""
    if [ -n "${OCI_IMAGE_ANNOTATION_VERSION}" ]; then
        vendor_arg="--version ${OCI_IMAGE_ANNOTATION_VERSION}"
    fi


    # Reconstruct image name to give as path to image oci
    image_name="${IMAGE_NAME}${IMAGE_NAME_SUFFIX}-oci"

    # Change into the image deploy dir to avoid having any output operations capture
    # long directories or the location.
    cd ${IMGDEPLOYDIR}

    ## lets add those annotations to the image
    bbdebug 1 "annoci --path ${image_name} \
        ${annotations_arg} \
        ${mounts_arg} \
        ${name_arg} \
        ${vendor_arg} \
        ${version_arg}"

    annoci --path ${image_name} \
        ${annotations_arg} \
        ${mounts_arg} \
        ${name_arg} \
        ${vendor_arg} \
        ${version_arg}
}
