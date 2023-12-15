LCM_OVERRIDE_ROOTFS_ENABLE ??= "y"

python do_lcm_override_rootfs_prepare_workdir () {
     from pathlib import Path
     lcmoverriderootfsenable = d.getVar("LCM_OVERRIDE_ROOTFS_ENABLE", False)
     workdirpath = d.getVar('WORKDIR', True)
     workoverriderootfspath = workdirpath + "/override_rootfs/"
     fpaths = (d.getVar('FILESPATH', True) or '').split(':')

     override_rootfs_path = None

     for dir in fpaths:
          if os.path.isdir(dir):
               rootfspath = dir + "/override_rootfs/"
               if os.path.isdir(rootfspath):
                    override_rootfs_path = rootfspath
                    break

     if os.path.exists(workoverriderootfspath):
          bb.utils.remove(workoverriderootfspath, True)
     bb.utils.mkdirhier(workoverriderootfspath)

     if lcmoverriderootfsenable is not "y":
          lcmoverriderootfsenable = "n"
     Path(workoverriderootfspath + "/enabled." + lcmoverriderootfsenable).touch()

     if override_rootfs_path is not None and lcmoverriderootfsenable is "y":
          import shutil
          rootfspath = workoverriderootfspath + "/rootfs/"
          shutil.copytree(override_rootfs_path, rootfspath, symlinks=True)
     else:
          Path(workoverriderootfspath + "/empty.state").touch()
}

do_lcm_override_rootfs_manipulate_rootfs () {
     rootfspath=${WORKDIR}/override_rootfs/rootfs/
     if [ -d "${rootfspath}" ]; then
          cd ${rootfspath};
          for d in $(find . -type d); do
               echo "Installing ${d}";
               install -d "${d}" "${IMAGE_ROOTFS}/$d";
               for f in $(find ${d} -type f -maxdepth 1); do
                    echo "Installing ${f}";
                    install -D "$f" ${IMAGE_ROOTFS}/${d}/;
               done
          done
     else
          echo "Cannot find ${rootfspath} - so no manipulation";
     fi
}

do_lcm_override_rootfs_manipulate_rootfs[dirs] = "${WORKDIR}/override_rootfs/"
do_lcm_override_rootfs_manipulate_rootfs[cleandirs] = "${WORKDIR}/override_rootfs/"

addtask lcm_override_rootfs_prepare_workdir before do_rootfs after do_prepare_recipe_sysroot
addtask lcm_override_rootfs_manipulate_rootfs after do_rootfs before do_image do_image_debugfs_tar do_image_oci do_rootfs_wicenv do_image_tar
