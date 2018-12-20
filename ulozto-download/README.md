# ulozto-download

## USAGE
<pre>
$ <b>ulozto-download</b> &lt;url&gt; &lt;output-file&gt; &lt;username&gt; &lt;password&gt;
</pre>

Synchronously downloads a file from uloz.to. Exits only when the entire file has been downloaded (if some problem occurs, keeps trying again indefinitely). If the *output-file* already exists, the program automatically continues the download (or exits immediately, if the file size is >= the remote file size).
