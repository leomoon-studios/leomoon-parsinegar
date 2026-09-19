# macOS release signing and notarization

macOS builds remain fully functional when no signing credentials are configured. Branch builds, pull requests, forks, and local builds produce unsigned DMG and PKG artifacts. Only tag builds attempt signing, and they do so only when the protected certificate secret is available.

To enable signing, export the Developer ID Application and Developer ID Installer identities, including their private keys, into one password-protected PKCS #12 file. Add its Base64 representation as the `MACOS_SIGNING_CERTIFICATE_BASE64` GitHub Actions secret, its password as `MACOS_SIGNING_CERTIFICATE_PASSWORD`, the exact application identity as `MACOS_APPLICATION_SIGNING_IDENTITY`, and the exact installer identity as `MACOS_INSTALLER_SIGNING_IDENTITY`.

To enable notarization, also add `MACOS_NOTARY_APPLE_ID`, `MACOS_NOTARY_TEAM_ID`, and `MACOS_NOTARY_APP_PASSWORD`. The password must be an app-specific password for the configured Apple ID. When all three values are present, the workflow stores a temporary notarytool profile, submits both the PKG and DMG, waits for approval, and staples the tickets.

The workflow creates a temporary keychain on the macOS runner, imports the signing material, signs the application and installer, and deletes the keychain and certificate file after packaging. Protect release tags and restrict access to these secrets to trusted maintainers. Fork pull requests do not receive repository secrets and continue to build unsigned artifacts.

For a local signed build, place the signing identities in your active keychain and set `PARSINEGAR_CODESIGN_IDENTITY` and `PARSINEGAR_INSTALLER_IDENTITY` before running `scripts/package-macos.sh`. A previously stored notarytool profile can be selected with `PARSINEGAR_NOTARY_PROFILE`; set `PARSINEGAR_NOTARY_KEYCHAIN` as well when that profile belongs to a non-default keychain.
