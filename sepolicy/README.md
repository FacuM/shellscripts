# patchsepolicy

Quickly patch sepolices in device tree.

## Usage

- Run `adb logcat | tee denials`
- Let it record some denials, then just hit `CTRL+C`.
- Copy the log and this script to your device tree.
- Run `bash patchsepolicy.sh denials`
- You can now delete the script and the denials file.

## Optional steps

Optionally, you can customize the behavior of the script by adding a file to your home (~).

- Create a file called ".patchsepoilicy_config.sh": `touch ~/.patchsepolicy_config.sh`
- Edit the file, add an array of strings with your desired settings:

The options are "private", "public", or both. I.e.: if you were to ignore private rules, just pass the following array.

`IGNORED_RULES=( 'private' )`

Once you're done, save the file. That's it, run the script and it'll be automatically detected and included.

## Credits

- To @Akianonymus for explaining me how to use audit2allow.
- To @Razhor for letting me borrow his VPS.
- To @edi194 for letting me borrow his VPS too (lel).
