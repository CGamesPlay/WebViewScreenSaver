# WebViewScreenSaver

This project is designed to enable web developers to easily create web pages
that can be used as native screensavers on Mac OS X. The prebuilt binary should
be sufficient in most cases, and can be modified without even requiring Xcode.

## How does it work?

Modify these directions as appropriate, but assuming that you are using the
prebuilt binary, simply open up the
`WebViewScreenSaver.saver/Contents/Info.plist` file, and adjust the values. The
four keys that you need to modify in particular are:

* `CFBundleName` - this is the string that will be displayed to the user in the
  list of screen savers.
* `PrimaryURL` - this is the main URL that will be displayed when the screen
  saver is activated. Can be relative to the Resources directory in the bundle,
  or an HTTP URL.
* `ConfigureURL` - this is the URL that will be displayed when the user is on
  the configuration page. If you remove this value, it indicates that there is
  no configuration for the screensaver. Since you can't uses cookies or
  localStorage, this options doesn't really make sense.
* `ConfigureFrame` - the width and height of the configuration panel.

If you want to host the application locally, you can simply place you files in
the `WebViewScreenSaver.saver/Contents/Resources/site/` directory and update the
plist accordingly.

# What needs to be done

* Default.png, or at least a matte color for before the view is loaded.
* It needs to prevent input (for preview window).
* Probably related: pressing keys doesn't dismiss the screensaver.
* LocalStorage storage works, however it stores data in `~/Library/WebKit`,
  shared with other WebViews.
* Web SQL Databases don't work.
* Cookies are shared with Safari.

# Thanks

I borrowed some code from [liquidx's
webviewscreensaver](https://github.com/liquidx/webviewscreensaver/), so mad
propz.
