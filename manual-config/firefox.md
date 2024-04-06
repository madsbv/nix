# Hide tab bar (for sidebar tab plugins)

Inside the profile folder (go to `about:profiles` to find this), add `chrome/userChrome.css` with the following contents:

``` css
#tabbrowser-tabs {
    visibility: collapse !important;
}
#titlebar {
    appearance: none !important;
    height: 0px;
}
#titlebar > toolbar-menubar {
    margin-top: 0px;
}
#TabsToolbar {
    min-width: 0px !important;
    min-height: 0px !important;
}
#TabsToolbar > .titlebar-buttonbox-container {
    display: block;
    position: absolute;
    top: 12px;
    left: 0px;
}
```

Then in `about:config`, set the option `toolkit.legacyUserProfileCustomizations.stylesheets` to `true` and restart Firefox.

To leave space for the close/minimize/maximize buttons on MacOS, go to 'customize toolbar' and add a flexible space to the left of the back/forward arrows.
