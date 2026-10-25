# PHP 5.4, 5.5 and 5.6 patched Windows builds

This folder contains nine separate Windows runtime ZIPs and their matching source patches in [patches/](patches/). Each build uses one patch flavor on its matching source. The current XAMPP installation is unchanged.

Patch source: [Anton-Barinov/php2shell-patches](https://github.com/Anton-Barinov/php2shell-patches). These are unofficial community backports for unsupported PHP versions.

## Packages and matching patches

All packages are **x86 Thread Safe** and include CLI, CGI and the Apache 2.4 module. PHP 5.4 uses **VC9**; PHP 5.5/5.6 use **VC11 (Visual Studio 2012)**. Server binaries, extensions and compiler runtime libraries must be compatible.

| PHP / flavor | Runtime ZIP | Matching patch | Source base | Session upload progress |
|---|---|---|---|---|
| 5.4.45 community | [ZIP](php-5.4.45-community-backport-Win32-VC9-x86.zip) | [Patch](patches/php-5.4-community-backport.patch) | Original 5.4.45 | Disabled |
| 5.4.45 enhanced | [ZIP](php-5.4.45-enhanced-universal-Win32-VC9-x86.zip) | [Patch](patches/php-5.4-enhanced-universal.patch) | Original 5.4.45 | Preserved |
| 5.5.38 community | [ZIP](php-5.5.38-community-backport-Win32-VC11-x86.zip) | [Patch](patches/php-5.5-community-backport.patch) | Original 5.5.38 | Disabled |
| 5.5.38 enhanced | [ZIP](php-5.5.38-enhanced-universal-Win32-VC11-x86.zip) | [Patch](patches/php-5.5-enhanced-universal.patch) | Original 5.5.38 | Preserved |
| 5.6.40 community | [ZIP](php-5.6.40-community-backport-Win32-VC11-x86.zip) | [Patch](patches/php-5.6-community-backport.patch) | Original 5.6.40 | Disabled |
| 5.6.40 minimal | [ZIP](php-5.6.40-minimal-patch-Win32-VC11-x86.zip) | [Patch](patches/php-5.6-minimal.patch) | Original 5.6.40 | Disabled |
| 5.6.40 enhanced universal | [ZIP](php-5.6.40-enhanced-universal-patch-Win32-VC11-x86.zip) | [Patch](patches/php-5.6-enhanced-universal.patch) | Original 5.6.40 | Preserved |
| 5.6.40 minimal Remi | [ZIP](php-5.6.40-minimal-remicollet-Win32-VC11-x86.zip) | [Patch](patches/php-5.6-minimal-remicollet.patch) | Remi 5.6 backports | Disabled |
| 5.6.40 enhanced Remi | [ZIP](php-5.6.40-enhanced-remicollet-Win32-VC11-x86.zip) | [Patch](patches/php-5.6-enhanced-remicollet.patch) | Remi 5.6 backports | Preserved |

## Differences between flavors

- **Community-backport:** a smaller set of changes that force-disables PHP's session-based upload-progress tracker. The PHP 5.4/5.5 patches include additional multipart `post_max_size` guards; the PHP 5.6 community patch does not add those guards.
- **Minimal:** force-disables the tracker and includes the additional multipart size guards. The plain patch targets original PHP 5.6.40; `minimal-remicollet` targets Remi's source.
- **Enhanced-universal:** preserves upload progress, changes its counter handling, and adds session/serialization hardening, filename sanitization for progress-session data, and multipart size guards. It targets original PHP releases.
- **Enhanced-remicollet:** provides the enhanced behavior for Remi's source, which already includes earlier security backports and still reports PHP 5.6.40.

Normal file uploads remain available in every flavor. Disabling the tracker affects progress bars that depend on PHP's session upload-progress feature. Setting `session.upload_progress.enabled=1` cannot restore it in a force-disabled build, even if `ini_get()` reports `1`.

All flavors change affected memory-allocation failure paths to terminate the process with `_exit(1)`, limit retained multipart MIME headers and reset HTTP global-variable pointers during shutdown. Process termination can interrupt other requests sharing the same Apache process.

## Source versions and patch application

The patches apply to source code and require compilation. They cannot be applied to `php.exe`. Use one chosen patch on a clean matching source tree; do not stack flavors or apply a patch twice.

| Source | Repository and tag/branch |
|---|---|
| PHP 5.4.45 | [php/php-src](https://github.com/php/php-src), tag `php-5.4.45` |
| PHP 5.5.38 | Same repository, tag `php-5.5.38` |
| Original PHP 5.6.40 | Same repository, tag `php-5.6.40` |
| Remi PHP 5.6 | [remicollet/php-src-security](https://github.com/remicollet/php-src-security), branch `PHP-5.6-security-backports` |

For example, run these commands from the root of clean original PHP 5.6.40 source, running the second command only if the check succeeds:

```powershell
git apply --check D:/_code/php5-patched-builds/patches/php-5.6-minimal.patch
git apply D:/_code/php5-patched-builds/patches/php-5.6-minimal.patch
```

The runtime version may remain `5.6.40`; use the ZIP name and available build metadata to identify the flavor. Eight ZIPs contain build records under `build-info/`; the earlier enhanced-universal PHP 5.6 ZIP does not.

## Collect information for a Linux build

Copy [collect-php-build-info.sh](collect-php-build-info.sh) to the remote Linux server and run it from a private directory outside the website root:

```bash
bash collect-php-build-info.sh > php-build-info.txt
```

The script prints the Linux version, CPU architecture, system C library, PHP version, extensions and Apache/Nginx version. It also checks Apache's PHP/FastCGI modules, running PHP-FPM process names and configuration filenames containing PHP handlers. It does not change the server or dump configuration contents. Send the resulting `php-build-info.txt` file. Both handlers can coexist for different sites; website PHP may differ from command-line PHP.

## Validation

All nine collected patches passed clean-source application checks, and their resulting runtime sources matched the saved build workspaces. Compiled packages underwent the targeted checks recorded during their builds; coverage differed between packages. These checks do not establish full PHP test-suite coverage, a complete security audit, or live application compatibility under Apache.

Build working folders, separate checksum files and detailed build Markdown files have been removed. The ZIP contents and collected patch files have been preserved.
