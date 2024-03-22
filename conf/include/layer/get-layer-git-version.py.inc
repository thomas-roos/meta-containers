def get_layer_git_version(d):
    import subprocess
    import os.path

    try:
        parentRepo = d.getVar("LAYERDIR", True)
        return subprocess.check_output(["git", "describe", "--tags", "--long","--dirty"], cwd = parentRepo, stderr = subprocess.DEVNULL).strip().decode('UTF-8')
    except Exception as inst:
        bb.warn(str(type(inst)) + ": " + str(inst))
        bb.warn("Could not determine layer git version. Default naming schema will be used with ${DATETIME}")
        return "${DATETIME}"

