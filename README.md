# Dotfiles

## Pre-requisites

1. Xcode Command Line Tools -> Git
   1. `xcode-select --install`
2. Add SSH RSA key to BitBucket
   1. `ssh-keygen` (just fast click thru steps)
   2. `open https://jira.internal.priority-health.com/stash/plugins/servlet/ssh/account/keys/add`
   3. `pbcopy < ~/.ssh/id_rsa.pub`
3. Install dotfiles
   1. `git clone ssh://git@bitbucket.spectrum-health.org:7999/ews/dotfiles.git ~/.dotfiles`
   2. `export PATH=$HOME/.dotfiles/bin:$PATH`
4. Optional:
   1. Read [PREFACE.md](https://bitbucket.spectrum-health.org:7991/stash/projects/EWS/repos/dotfiles/browse/PREFACE.md)
   2. Add files to `$DOTFILES_HOME/personal`. The types of files that you would add here are described in the PREFACE.

## Usage

### `dotfiles [options] [install_level] [args...]`

There are a few options here:

1. Express (***NOTE: does not set up your workspace***)

   ```bash
   dotfiles run --express
   ```

2. Complete

   ```bash
   dotfiles run --full
   ```

3. Custom

   TBD

## Additional Usage

### `dotbot [options] [module] [operands...] [args...]`

The options are as follows:

1. Add

   ```bash
   dotbot add projects
   ```

2. Create

   ```bash
   dotbot create workspace
   ```

3. Doctor

   TBD

4. Help

   ```bash
   dotbot help
   ```

5. Install

   ```bash
   dotbot install bundle
   ```

   ```bash
   dotbot install bundle --brewfile=<location>
   ```

6. Set

   ```bash
   dotbot set java 1.8 --apply-artifactory-cert
   ```

   ```bash
   dotbot set maven
   ```

   ```bash
   dotbot set git
   ```

   ```bash
   dotbot set shell
   ```

7. Status

   ```bash
   dotbot status git
   ```

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