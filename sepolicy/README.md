# patchsepolicy

Quickly patch sepolices in device tree.

## Usage

- Run `adb logcat | grep avc | tee denials`
- Let it record some denials, then just hit `CTRL+C`.
- Run `audit2allow < denials > sepolicyfix`
- Copy both denils and this script to your device tree.
- Run `bash patchsepolicy.sh sepolicyfix`
- You can now delete the script and the denials file.

## Credits

- To @Akianonymus for explaining me how to use audit2allow.
- To @Razhor for letting me borrow his VPS.

