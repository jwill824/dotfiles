# Dotfiles

## What are dotfiles and why should I use them

Dotfiles are text configuration files for UNIX-type systems. They are called "dotfiles" as they typically are named with a leading `.`, making them hidden files on your system, although this is not a strict requirement.

### [dotfiles](https://dotfiles.github.io/) by GitHub and the community

GitHub created a dotfiles space, an aggregation of developer's system preferences (all on GitHub), that spans all of the type of content you'd expect from those who use the command line.

The following is a list and excerpt from the site summary:

> - Backup, restore, and sync the prefs and settings for your toolbox. Your dotfiles might be the most important files on your machine.
> - Learn from the community. Discover new tools for your toolbox and new tricks for the ones you already use.
> - Share what you’ve learned with the rest of us.

### Why does EWS need dotfiles

The point for us to utilize the dotfile concept is to keep a _structured_ and _concise_ provisioning method (for our machines) at the tip of our fingers at times when we need to provision quickly, and in quantity.

Despite having standards in mind, developers will always be unique, and the dotfiles should not take away from developer's personal preferences. That's why you will notice that our "dotfiles" really are not typical, in the sense that there does not exist multiple files with leading dots. Our focus lies within the script that will help you essentially "glue" the dotfiles of your choice together. So when you hear "dotfiles" going forward, think of this repository, the script, but not the actual files.

Despite all the customizable content, you still have to run the `dotfiles` script to ensure that certain tasks are accounted for. And that's the benefit of having this repository, is that it's here for those that don't want to do the scrupulous tasks. Think of it as a tool to help organize your system files, libraries, applications, etc.

#### Personalize them yourself

Yes, you heard right. You will be able to personalize your computer to your liking. There are several ways you can do this.

- Create your own dotfiles repository in GitHub.

OR

- Fork this repository and commit how you want to implement dotfiles.

OR

- Add the dotfiles you want to the recommended directory. You have to create this directory in `$DOTFILES_HOME` (the root directory in this repository) and call it `personal` (since it's your personal directory - who would have guessed?!). The script will do the rest.

One thing to note is that all the ways involve using the `dotfiles` script prior to doing anything. This is required because the dotfiles script does things that are necessary for you to start developing.

### Core things to understand

Before you can start provisioning your machine, there are some terms you will have to be acquainted with.

#### .bash_profile

The `.bash_profile` file is a dotfile that is executed when you run a *login shell* (verses *interactive shell* like when `.bashrc` is typically executed). Calling `ps -f` will display your current login shell processes. In macOS, (formerly OS X), Terminal, by default, runs a login shell every time.

```bash
$ ps -f
  UID   PID  PPID   C STIME   TTY           TIME CMD
305077702 28386   589   0 14Nov18 ttys001    0:08.25 bash --login
305077702 15884  5087   0 11:06AM ttys002    0:00.03 /bin/zsh -l
```

To picture when `.bash_profile` gets executed, understand that there are a sequence of events that occur before the initial command prompt. `~/.bash_profile` is called after `/etc/profile`, but before `~/.bash_login` and `~/.profile`, *in that order*.

Sequence of files on login:

1. `/etc/profile`
2. `~/.bash_profile`
3. `~/.bash_login`
4. `~/.profile`

And on logout, `~/.bash_logout` is called.

`.bash_profile` allows you to specify a multitude of things that are otherwise not kept in an organized location. This includes **environment variables**, **aliases**, **path variables**, **profiles**, and any other shell scripting directives. There's really no limit to what you can put into your `.bash_profile`. However, it's common for those to keep it clean for readability's sake. Here are the common sections usually included:

- environment variables

  ```bash
  $ printenv
  TERM_PROGRAM=Hyper
  TERM=xterm-256color
  SHELL=/bin/zsh
  TMPDIR=/var/folders/k8/qjvjqsdn40l5d4dmq0fvypb892y7f6/T/
  Apple_PubSub_Socket_Render=/private/tmp/com.apple.launchd.PQhH9aBrUr/Render
  TERM_PROGRAM_VERSION=2.0.0
  OLDPWD=/opt/spectrum_health/dotfiles
  USER=<username>
  SSH_AUTH_SOCK=/private/tmp/com.apple.launchd.7GO5pmpNlm/Listeners
  __CF_USER_TEXT_ENCODING=0x122F1DC6:0x0:0x0
  MAVEN_OPTS=-Xmx512m -Djava.awt.headless=true
  TNS_ADMIN=/opt/spectrum_health/oracleTns/network/admin
  PATH=/bin:/Users/<username>/.jenv/bin:/opt/spectrum_health/bin:/Users/<username>/.dotfiles/bin:/Users/<username>/.dotfiles/bin/cbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
  WORK=/opt/spectrum_health
  JENV_LOADED=1
  PWD=/opt/spectrum_health
  LANG=en_US.UTF-8
  EXT_DOTFILES_HOME=/Users/<username>/.dotfiles/personal
  XPC_FLAGS=0x0
  PS1=[\u@\h \w]\[$(git_color)\]$(parse_git_branch_and_add_brackets)\[\033[0m\]\n$
  HOME_BIN=/opt/spectrum_health/bin
  XPC_SERVICE_NAME=0
  M2_HOME=/Users/<username>/.m2
  SHLVL=1
  HOME=/Users/<username>
  DOTFILES_HOME=/Users/<username>/.dotfiles
  LOGNAME=<username>
  COLORTERM=truecolor
  _=/usr/bin/printenv
  ```

- aliases

  ```bash
  $ alias
  alias bin='cd /opt/spectrum_health/bin'
  alias brew='all_proxy=http://<username>:@proxy.spectrum-health.org:9090 brew'
  alias dot='cd /Users/<username>/.dotfiles'
  alias l='ls -al'
  alias ll='ls -l'
  alias tns='cd /opt/spectrum_health/oracletns/network/admin'
  alias wg='cd /opt/spectrum_health'
  ```

- path variable (environment variable)

  ```bash
  export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
  ```

- additional profiles

  ```bash
  source $EXT_DOTFILES_HOME/.git_profile
  ```

- etc

#### .git_profile

The `.git_profile` is a concept that might not be entirely (sourced) from us but primarily is something that EWS created to organize `git config` and other git related configuration items. It's a dotfile that is sourced from `.bash_profile`.

You will not be required to create a `.git_profile`! This is based on your preferences. You will probably want to create something like it, however. Or even just run the `git config` commands manually within the `.bash_profile`.

Here's an example of what our `.git_profile` looked like in the past:

```bash
#!/bin/sh

COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[0;33m"
COLOR_GREEN="\033[0;32m"
COLOR_OCHRE="\033[38;5;95m"

function git_color {
  local git_status="$(git status 2> /dev/null)"

  if [[ $git_status =~ "not staged for commit" ]]; then
    echo -e $COLOR_RED
  elif [[ $git_status =~ "to be committed" ]]; then
    echo -e $COLOR_YELLOW
  elif [[ $git_status =~ "branch is ahead of" ]]; then
    echo -e $COLOR_YELLOW
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e $COLOR_GREEN
  fi
}

function parse_git_branch_and_add_brackets {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}
PS1="[\u@\h \w]\[\$(git_color)\]\$(parse_git_branch_and_add_brackets)\[\033[0m\]\\n$ "
export PS1

. $DOTFILES_HOME/git-completion.bash
```

Essentially what the above does is it adds git "branch names within brackets", that tells you what branch you're currently on, and if you have anything uncommitted, or unstaged, or even untracked files. Also you can see that you can source `git-completion.bash`, if you wanted to modify this yourself. Ideally, you would not do this, you would use something out-of-the-box, but it's the place you _could_ add functionality like this.

Below you will see what this might look like in your terminal. (_Note: that `[develop]` would be colorized_)

```bash
[<user>@<computer> /opt/spectrum_health] [develop]
$
```

If you are to create a `.git_profile`, it can contain whatever you want. Don't get the idea that it needs to contain everything above.

`.git_profile` will also typically source another, more common dotfile, `.gitconfig`. This is related to what was mentioned above about running `git config` commands. You can read up on what the `.gitconfig` is [here](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup). Essentially, this file is the equivalent of calling the `git config` command. An example of what a file looks like, can be seen below:

```text
[alias]
  co = checkout
  st = status
  br = branch -v
  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(red)<%an>%Creset' --abbrev-commit --date=local
[hub]
  protocol = https
[user]
  name = Firstname Lastname
  email = username@email.com
[credential]
  helper = osxkeychain
```

Like what has been said many times, the file above can actually be translated into individual commands on the command line (with the addition that you can used custom in-line variables):

```bash
git config --global user.email "username@email.com"
git config --global user.name "$(osascript -e 'long user name of (system info)')"
git config --global alias.co "checkout"
git config --global alias.st "status"
git config --global alias.br "branch -v"
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(red)<%an>%Creset' --abbrev-commit --date=local"
```

The `dotfiles` script will keep most of the basic git aliases that you can see above, but you will be on your own if you want to add anything else - _which is the idea_!

#### Brewfile

Before we can explain what a Brewfile is, you have to become acquainted with [Homebrew](https://brew.sh/). Homebrew is a package management system for macOS that helps install software for your computer. This software ranges from simple tools, to complex libraries, and with the addition of Casks, Mac applications. [Casks](https://github.com/Homebrew/homebrew-cask) are an extension of Homebrew and allow you to install applications, such as text editors, IDEs, and many other tools. Along with that, Homebrew even integrates with the Apple Mac Store applications.

Below is a table straight from the [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook#homebrew-terminology) page that describes the many different terminologies involved with Homebrew.

| Term            | Description                                                  | Example                                                      |
| --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Formula**     | The package definition                                       | `/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/foo.rb` |
| **Keg**         | The installation prefix of a **Formula**                     | `/usr/local/Cellar/foo/0.1`                                  |
| **opt prefix**  | A symlink to the active version of a **Keg**                 | `/usr/local/opt/foo`                                         |
| **Cellar**      | All **Kegs** are installed here                              | `/usr/local/Cellar`                                          |
| **Tap**         | A Git repository of **Formulae **and/or commands             | `/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core`    |
| **Bottle**      | Pre-built **Keg** used instead of building from source       | `qt-4.8.4.mavericks.bottle.tar.gz`                           |
| **Cask**        | An [extension of Homebrew](https://github.com/Homebrew/homebrew-cask) to install macOS native apps | `/Applications/MacDown.app/Contents/SharedSupport/bin/macdown` |
| **Brew Bundle** | An [extension of Homebrew](https://github.com/Homebrew/homebrew-bundle) to describe dependencies | `brew 'myservice', restart_service: true`                    |

So, with that all being said, you will notice that there exists what's known as a _Brew Bundle_. A bundle is exactly how it's described, as an extension of Homebrew that allows you to define dependencies. This is done through a [Brewfile](https://github.com/Homebrew/homebrew-bundle). The structure is defined on the previous link, but it goes like this:

```ruby
cask_args appdir: "/Applications" # Target location for all casks (know that kegs are placed in the Cellar by default)

tap "homebrew/cask" # Needed to locate cask definitions

# Keg entries
brew "java" # Can be as simple as this...
brew "mysql@5.6", restart_service: true, link: true, conflicts_with: ["mysql"] # Or as detailed as this, depending on the Keg...

# Cask entries
cask "google-chrome" # The same goes for casks...
cask "java" unless system "/usr/libexec/java_home --failfast" # This is interesting
cask "firefox", args: { appdir: "~/my-apps/Applications" } # This is cool
```

As a reminder, though, know that the above can vary and become more complex with time, as you add more and more to it.

As a comparison, EWS's Brewfile is as simple as this:

```ruby
cask_args appdir: "/Applications"
tap "caskroom/cask"     # required for casks
tap "caskroom/versions" # required to get casks that are versioned, like Java 8

cask "java8" # Java 8 
cask "java"  # The latest Java version
brew "jenv"  # Java version/environment switcher
brew "maven" # Maven
brew "wget"  # needed for getting maven settings xml
```

The purpose for this is, is for everyone to expand on this and create their own Brewfile. Your workflow is your workflow, meaning the apps and tools you need to do your work, is an extension of your personality and tastes.

Now you might be wondering, how do you use the Brewfile? Well, that's as simple as running the `brew` command with the bundle option. You can find this in the Brewfile link above.

```bash
brew bundle
```

One thing to note, however, is that this expects your Brewfile in your `$HOME` directory. This can be offset by running the command with this argument:

```bash
brew bundle --file=$LOCATION_OF_YOUR_BREWFILE
```

The `dotfiles` script utilizes this feature to run the Brewfile stored within the dotfiles directory, and the possibility for you to run your Brewfile from within the `$DOTFILES_HOME/personal` directory.

## How EWS dotfiles are structured

```bash
$ tree -L 5 -I .git -a
.
├── .bash_profile
├── .gitignore
├── Brewfile
├── PREFACE.md
├── README.md
├── bin
│   ├── cbin
│   │   ├── dotbot
│   │   └── vbin
│   │       ├── _add
│   │       ├── _create
│   │       ├── _install
│   │       ├── _set
│   │       └── mbin
│   │           ├── _bundle
│   │           ├── _defaults
│   │           ├── _git
│   │           ├── _java
│   │           ├── _maven
│   │           ├── _shell
│   │           └── _workspace
│   └── dotfiles
├── personal
│   ├── .bashrc
│   ├── .defaults
│   ├── .git_profile
│   ├── .gitconfig
│   ├── Brewfile
│   └── git-completion.bash
└── resources
    └── artifactory.cert

6 directories, 27 files
```

Snippet of optional files and directories:

> ```
> ├── personal (ignored - optional)
> │   ├── .bashrc (optional)
> │   ├── .defaults (optional)
> │   ├── .git_profile (optional)
> │   ├── .gitconfig (optional)
> │   ├── Brewfile (optional)
> │   └── git-completion.bash (optional)
> └── resources (ignored)
>     └── artifactory.cert (downloaded)
> ```

So inside the `.gitignore` you will notice the following:

- resources
- personal

This is because `resources` is used inside the script to download a file that is sensitive to your user account. And the `personal` directory is a place for you to add your own custom dotfiles to the script itself, which it will then handle appropriately.

### What does the dotfiles script do

> ```text
> ├── bin
> │   ├── cbin (component)
> │   │   ├── dotbot (underlying 'tooling' script)
> │   │   └── vbin (verb)
> │   │       ├── _add       -> join (something) to something else.
> │   │       ├── _create    -> bring (something) into existence.
> │   │       ├── _install   -> place (something) in position ready for use.
> │   │       ├── _set       -> put (something) in a specified place or position.
> │   │       ├── _status    -> check (something)'s state.
> │   │       └── mbin (module)
> │   │           ├── _bundle
> │   │           ├── _defaults
> │   │           ├── _git
> │   │           ├── _java
> │   │           ├── _maven
> │   │           ├── _shell
> │   │           └── _workspace
> │   └── dotfiles (interface script)
> ```

The script is interfaced by a cli tool simply called `dotfiles`. This has a `run` argument that also requires another argument based on the type of installation. These arguments determine how the script is ran. Moreso, they determine what arguments are given to a sub-script, called the `dotbot`. This `dotbot` script modularizes the nature of everything EWS needs from a developer standpoint.

These are the permutations currently possible:

* **complete**

  This permutation expects that you accept that the script will control the directory structure of your workspace. Also it expects you will have added any dotfiles to the `$DOTFILES_HOME/personal` location.

    ```bash
    dotbot -C workspace
    dotbot -a projects
    dotbot -S shell bash
    dotbot -S maven
    dotbot -S java 1.8 --apply-artifactory-cert
    source $HOME/.bash_profile
    ```

* **express**

  This permutation forgoes constructing the workspace and assumes that you will do this yourself.

  ```bash
  dotbot -I bundle
  dotbot -S java 1.8
  dotbot -S maven --apply-artifactory-cert
  source $HOME/.bash_profile
  ```

* **custom**

  TBD

## What your machine will look like afterwards, a glimpse

### ~/. ($HOME)

```bash
$ l
total 0
drwxr-xr-x+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .
drwxr-xr-x   0 root        admin                             0 MMM dd hh:mm ..
drwx------   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .Trash
-rw-r--r--   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .anyconnect
lrwxr-xr-x   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .bash_profile -> /opt/spectrum_health/dotfiles/.bash_profile
drwxr-xr-x   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .cisco
drwxr-xr-x   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .dotfiles
-rw-r--r--   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .gitconfig
drwxr-xr-x   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .jenv
drwxr-xr-x   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .m2
drwx------   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm .ssh
drwx------@  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Applications
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Desktop
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Documents
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Downloads
drwx------@  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Library
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Movies
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Music
drwxr--r--   0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm MyJabberFiles
drwx------+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Pictures
drwxr-xr-x+  0 <username>  SPECTRUM-HEALTH\Domain Users      0 MMM dd hh:mm Public
```

### /opt/spectrum_health ($WORK)

This will be the directory that you will interact with the most, probably more than any other directory on your system. And that's the point. It absracts the complexities into an organized space. This includes a mixture of version controlled files and system files. By default, most system files are put in obscure places that are system controlled directories or on the `$HOME` directory.

```bash
$ ll
total 0
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm bin
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm config
lrwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm dotfiles -> /Users/<username>/.dotfiles
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm lib
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm projects
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm oracletns
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm resources
drwxr-xr-x   0 <username>  staff    0 MMM dd hh:mm settings
```

An example of the structure of the directory, *one* directory deep (_this command does not include symlinks_):

```bash
$ tree -L 2
.
├── bin
│   ├── README.md
│   ├── furl
│   ├── furl-completion
│   ├── get_password_for
│   ├── gitfix.sh
│   ├── helm-archetype
│   ├── legacy
│   └── readme
├── configs
│   ├── 3scale-config-nonprod
│   ├── delivery-configs
│   ├── delivery-secrets
│   ├── insurance-configs
│   └── insurance-secrets
├── dotfiles -> /Users/<username>/.dotfiles
├── lib
│   ├── archetype
│   ├── serviceutil
│   └── soa-common
├── projects
│   ├── appEnrollment
│   ├── calendarevents
│   ├── consumerDataSurvey
│   ├── identityVerification
│   ├── imagingresult
│   ├── interconnect
│   ├── memberPatientMatch
│   ├── message
│   ├── scheduler
│   ├── shProvider
│   ├── talentConnection
│   ├── timeline-3
│   └── videoConferencing
├── oracletns
│   └── network
├── resources
│   ├── ews-standards
│   ├── helm
│   └── readme_template
└── settings
    ├── intellij_settings.jar
    ├── postman_settings.json
    └── vscode_settings.json

38 directories, 7 files
```

A couple notes:

- The following directories are version controlled:
  - `bin`
  - `oracletns`
- The following directories are to organize other git controlled repositories:
  - `config`
  - `lib`
  - `projects`
  - `resources`
- This directory will allow you to organize your dotfiles and keep your application settings files in order, by symlinking them:
  - `settings`

### /usr/local

This directory is singled out because it houses a lot of  important sub-directories. Homebrew designates this a target location for anything downloaded into the Caskroom, or put into the Cellar, along with Homebrew self specific files.

```bash
$ ll
total 0
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm Caskroom
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm Cellar
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm Homebrew
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm bin
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm etc
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm include
drwxr-xr-x    ~ root      wheel     ~ MMM dd hh:mm jamf
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm lib
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm opt
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm sbin
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm share
drwxrwxr-x    ~ username  admin     ~ MMM dd hh:mm var
```

## Caveats

## How to make changes

## References

- [Getting Started with Dotfiles](https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789) by Lars Kappert
- [My Mac OSX Bash Profile](https://natelandau.com/my-mac-osx-bash_profile/) by Nathaniel Landau