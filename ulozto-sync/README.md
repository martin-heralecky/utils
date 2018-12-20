# ulozto-sync

## USAGE
<pre>
$ <b>ulozto-sync</b> [options] &lt;url&gt;
</pre>

Downloads a file from uloz.to, encrypts it and uploads to Google Drive under randomly generated name.

*FILE_ORIGINAL* and *FILE_ENCRYPTED* are removed before and after the synchronization.

If the synchronization was successful, appends the signature of the synced file to *SIGNATURES_FILE*.

## OPTIONS
<pre>
<b>-c</b> &lt;file&gt;    Specifies the configuration file.
             optional, default: ~/.config/ulozto-sync
</pre>

## CONFIGURATION FILE
Contains declaration of configuration variables. Is loaded via `. <config-file>`.

<pre>
ULOZTO_USERNAME     Username for the uloz.to account.
                    required
ULOZTO_PASSWORD     Password for the uloz.to account.
                    required
FILE_ORIGINAL       Location, where the original file will be stored.
                    optional, default: /tmp/ulozto-sync.orig
FILE_ENCRYPTED      Location, where the encrypted file will be stored.
                    optional, default: /tmp/ulozto-sync.enc
GPG_RECIPIENT       Recipient in context of the GnuPG encryption.
                    required
REMOTE_DIRECTORY    ID of the Google Drive directory where the encrypted file should be uploaded.
                    required
SIGNATURES_FILE     File containing signatures of the synced files.
                    required
</pre>

## DEPENDENCIES
`ulozto-download`, `gpg`, `gdrive`

Enough disk space for both FILE_ORIGINAL and FILE_ENCRYPTED to be stored.
