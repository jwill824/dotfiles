# Dotfiles

## Pre-requisites

1. Download Xcode
1. Install Xcode Command Line Tools -> Git
   1. `xcode-select --install`
1. Add SSH RSA key to BitBucket or Github
   1. `ssh-keygen` (just fast click thru steps)
   2. `open https://jira.internal.priority-health.com/stash/plugins/servlet/ssh/account/keys/add`
   3. `pbcopy < ~/.ssh/id_rsa.pub`
1. Install dotfiles
   1. `git clone {ssh_git_url} ~/.dotfiles`
   2. `export PATH=$HOME/.dotfiles/bin:$PATH`
1. Optional:
   1. Read PREFACE.md
   2. Add files to `$DOTFILES_HOME/personal`. The types of files that you would add here are described in the PREFACE.

## Usage

TBD

## Changes

### How to modify

#### Adding a new module or action (verb)

1. Create new bash script with file ending `.sh` in `dotfiles/bin/cbin/vbin` or `dotfiles/bin/cbin/vbin/mbin` directory
2. Make sure script has `#!/bin/sh` heading
3. Run `chmod u+x` on file
4. Remove `.sh` extension

#### What are different script levels

1. dotfiles
    2. component
        3. verb (action)
            4. module

The difference between a _module_ and _action_ can be seen in the context of the scripts themselves. Action scripts have switch cases with the modules denoted in the case body. Action scripts are supposed to be very modular. On the other hand, module scripts have the bulk of the comprehension. This is because the action scripts call the module scripts.

#### Naming

When creating a new action script, understanding the verbage is important. Currently, the verbage includes:

* add
* create
* doctor
* install
* set
* status

Each of the above "verbs" 

#### Update command prompt print lines and readme

After you've added an action, or a module, make sure to update the documentation. This should be apparent, but it's easy to forget this step.

## What to do next

### Self Service

Make sure to install Google Chrome from self service. It contains the fixes that allows one to SSO into several Spectrum Health domains.

### Run `furl`

### Share
