# emacs-clockify

An emacs plugin to make time entries into https://clockify.me

## Install

Add this to your config file

``` emacs-lisp
(use-package clockify
  :load-path "~/projects/emacs-clockify"
  :init
  (setq clockify-api-key "<api-key>")
  (setq clockify-workspace "<workspace-id>")
)

```

You need to clone this repo to the path you mention in the `:load-path` as this package is not yet available on MELPA.

## Usage

In any emacs session use `M-X` and call the `clockify-get-projects` once to populate all the projects from your workspace.

Then run `clockify-clock` whenever you want to clock in a time entry. It will show a nice popup where you can search for your project, search for start time, and end time. Really quick!

## TODO

- [ ] I'm working on a better way to store the api key and workspace id, probably in a file like `~/.emacs-clockify`
- [ ] Remove the need to call `clockify-get-projects` manually
- [ ] Screenshot / GIF
