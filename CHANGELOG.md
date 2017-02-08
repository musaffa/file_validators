# 2.2.0-beta.1

* [#17](https://github.com/musaffa/file_validators/pull/17) Now Supports multiple file uploads
* As activemodel 3.0 and 3.1 doesn't support `added?` method on the Errors class, the support for both of them have been deprecated in this release.

# 2.1.0

* Use autoload for lazy loading of libraries.
* Media type spoof valiation is moved to content type detector.
* `spoofed_file_media_type` message isn't needed anymore.
* Logger info and warning is added.
