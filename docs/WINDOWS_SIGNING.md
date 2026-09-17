# Windows release signing

Windows builds remain fully functional when no signing credentials are configured. Branch builds, pull requests, forks, and local builds produce unsigned installers. Only tag builds attempt signing, and they do so only when the protected certificate secret is available.

To enable signing, add `WINDOWS_SIGNING_CERTIFICATE_BASE64` and `WINDOWS_SIGNING_CERTIFICATE_PASSWORD` as GitHub Actions secrets. The first value is the Base64 representation of a code-signing PFX file. Protect release tags and restrict access to these secrets to trusted maintainers. The workflow writes the certificate to the temporary runner directory, signs the application before Inno Setup packages it, signs the completed installer with SHA-256 and a timestamp, and deletes the temporary certificate at the end of the job.

Do not store the PFX file, its password, or its Base64 representation in the repository. Fork pull requests do not receive repository secrets and continue to build unsigned artifacts.
