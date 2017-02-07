# Homebrew Packages

Manages homebrew packages through attributes.

## Requirements

### Platforms

- `mac_os_x`

### Chef

- Chef 12.0 or later

## Attributes

Determine if failures should be ignored(Default: `false`):

```json
{
  "homebrew_packages" : {
    "ignore_failure" : true
  }
}
```

Global install options that will be run with each choco install (Default: `[]`)

```json
{
  "homebrew_packages" : {
    "install_options" : [
      "--debug"
    ]
  }
}
```

Define packages:

```json
{
  "homebrew_packages" : {
    "packages" : {
      "vim": {
        "action": "8.0.0311"
      },
      "wget": {
        "action": "upgrade"
       },
      "nginx": {
        "action": "install",
        "install_options": [
          "--only-dependencies"
         ]
      },
      "sl": {
        "action": "purge"
      },
      "google-chrome": {
        "action": "upgrade",
        "cask": true
      }
    }
  }
}
```

The `action` field follows the same actions as [this documentation](https://docs.chef.io/resource_homebrew_package.html), it also can take a version number.

## Usage

### homebrew_packages::default

Just include `homebrew_packages` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[homebrew_packages]"
  ]
}
```



