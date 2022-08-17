# only relevant for aarch64 when using a kernel which does not have the memory taggin (smaller then 5.4)
# https://man7.org/tlpi/api_changes/
# PR_SET_TAGGED_ADDR_CTRL
PACKAGECONFIG:remove:aarch64 = "memory-tagging"
