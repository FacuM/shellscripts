# patchsepolicy

Quickly patch sepolices in device tree.

## Usage

- Run `adb logcat | tee denials`
- Let it record some denials, then just hit `CTRL+C`.
- Copy the log and this script to your device tree.
- Run `bash patchsepolicy.sh denials`
- You can now delete the script and the denials file.

## Credits

- To @Akianonymus for explaining me how to use audit2allow.
- To @Razhor for letting me borrow his VPS.
- To @edi194 for letting me borrow his VPS too (lel).
