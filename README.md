# nix-roleplay: Form a better relationship with your code

```
    .~-------~.
   /           \
  /    \ \./    \
 |    ":"""\ /   |
 |  '"/     V"'  |
  \  "\____/_   /
   \  /\   \   /
    \         /
     \       /
      \_____/

```
This is a nix-kiteshield, may it be of service to you.


## Table of contents


1. [Introduction](#introduction)

1.1 [What can be gained by using nix-roleplay?](#what-can-be-gained-by-using-nix-roleplay?)

1.2 [Handling module imports as lambdas](#handling-module-imports-as-lambdas)

1.3 [Splitting into machines, roles, mod_categories and modules](#splitting-into-machines,-roles,-mod_categories-and-modules)

1.4 [How to generalize?](#how-to-generalize?)

1.5 [Benefits of using a universal structure](#benefits-of-using-a-universal-structure)

2. [How to use as a flake](#how-to-use-as-a-flake)

3. [Roadmap](#roadmap)

4. [Contact](#contact)


## Introduction


I decided to come up with a solution for refactoring my code into general categories.

Those should be shareable between related configurations of machines.

So, roles were invented for that kind of distinction.

I played around until I found a low complexity (at least in my head) realisation which I could unleash to the world.

Therefore the name nix-roleplay.


### What can be gained by using nix-roleplay?


- An universal structure for organizing infrastructure flakes
- Advanced generalization of imports/modules
- Splitting multiple nixosConfigurations into machines, roles, mod_categories and modules
- [Handling module imports as lambdas](#handling-module-imports-as-lambdas) -> See [1.2](#handling-module-imports-as-lambdas)


### Handling module imports as lambdas


The 'func_mods' attribute is available in roles and mod_categories.

It possesses the "lambda-handling" superpower but also acts like the 'modules' attribute from a nixosConfiguration.

So normal module imports are still expected and malfunctions are considered bugs.

The superpower is automatically applied when using a module which looks like a function which expects a name argument.

The so called "function module" should return a list of modules.

example_function_module.nix:
```
{ name: }
if name == "someThing"
  then [
    (import "/someA/someA.nix")
  ]
  else [
    (import "/someB/${name}/someB.nix")
  ];
```

It would be imported like this:
```
func_mods = [
  import ./example_function_module.nix
];
```

In the future we could provide much more arguments and customizability by allowing a general attribute set to be passed.


### Splitting code into machines, roles, mod_categories and modules


This is the tree output for my 'infrastructure as code' repository:

```
├── flake.nix
├── nix-rp
│   ├── mod-categories.nix
│   └── roles.nix
│   ├── machines
│   │   ├── machines.nix
│   │   ├── machine_A
│   │   │   ├── nixos
│   │   │   │   ├── configuration.nix
│   │   │   │   ├── hardware-configuration.nix
│   │   │   │   ├── module-list.nix
│   │   ├── machine_B
│   │   │   ├── nixos
│   │   │   │   ├── configuration.nix
│   │   │   │   ├── hardware-configuration.nix
│   │   │   │   ├── module-list.nix
│   │   ├── machine_C
│   │   │   └── nixos
│   │   │       ├── configuration.nix
│   │   │       ├── module-list.nix
│   ├── modules
│   │   ├── modules.nix
│   │   ├── builders
│   │   │   ├── cross-compilation.nix
│   │   │   ├── home-manager.nix
│   │   │   ├── module-list.nix
│   │   │   ├── nix-daemon.nix
│   │   │   ├── users
│   │   │   │   ├── nix-serve
│   │   │   │   │   ├── cache-priv-key.pem
│   │   │   │   │   └── nix-serve.nix
│   │   │   ├── users.nix
│   │   ├── clients
│   │   │   ├── console.nix
│   │   │   ├── containers
│   │   │   │   ├── nspawn-containers.nix
│   │   │   │   └── oci-containers.nix
│   │   │   ├── fonts.nix
│   │   │   ├── home-manager.nix
│   │   │   ├── module-list.nix
│   │   │   ├── nix-daemon.nix
│   │   │   ├── nix-direnv.nix
│   │   │   ├── packages.nix
│   │   │   ├── security.nix
│   │   │   ├── services.nix
│   │   │   ├── ssh.nix
│   │   │   ├── users
│   │   │   │   └── nixDeveloper
│   │   │   │       ├── emacs
│   │   │   │       │   └── emacs.nix
│   │   │   │       ├── nixDeveloper.nix
│   │   │   │       ├── sops.nix
│   │   │   │       ├── ssh.nix
│   │   │   ├── users.nix
│   │   ├── common
│   │   │   ├── common.nix
│   │   │   ├── groups.nix
│   │   │   ├── module-list.nix
│   │   │   ├── networking.nix
│   │   │   ├── nix-daemon.nix
│   │   │   ├── sshd.nix
│   │   │   └── users.nix
│   │   ├── gaming
│   │   │   ├── modules.nix
│   │   ├── home-manager
│   │   │   ├── modules.nix
│   │   ├── images
│   │   │   ├── sshd.nix
│   │   ├── pi
│   │   │   ├── 1
│   │   │   │   ├── common.nix
│   │   │   │   └── module-list.nix
│   │   │   └── 4
│   │   │       ├── common.nix
│   │   │       ├── module-list.nix
│   │   ├── replication
│   │   │   ├── push.nix
│   │   │   ├── sink.nix
│   │   │   └── users
│   │   │       └── syncoid
│   │   │           ├── sops.nix
│   │   │           ├── syncoid.nix
│   │   ├── sops
│   │   │   ├── modules.nix
│   │   │   └── sops.nix
│   │   └── zfs
│   │       ├── module-list.nix
│   │       ├── zfs-boot.nix
│   │       └── zfs-hardware.nix
├── outputs
│   ├── images.nix
│   ├── apps
│   │   ├── apps.nix
│   ├── devshell
│   │   ├── devshell.nix
│   │   ├── devshells.nix
│   ├── nix-src
│   │   ├── main.nix
│   ├── outputs.nix
│   └── packages.nix
├── secrets
│   ├── general
│   │   └── general.yaml
│   ├── nixDeveloper
│   │   └── nixDeveloper.yaml
│   └── syncoid
│       └── syncoid.yaml
```

Each machine has it's own specific configuration but also shares common settings and configurations through roles.

Roles are for bundling multiple mod_categories or modules together.

Mod_categories also bundle modules but can be combined together in a role.


#### Note:


Roles could be fully ignored and instead modules would be imported trough the extra_modules attribute in a machine attrSet.


### How to generalize?


Well, I am a clean code enthusiast so after reading more than 4 lines of an attrSet I naturally feel the urge to refactor something.

It's hard to resist but it's a constant battle between refactoring and implementing new functionality.

At some point in your developer career you should sit down and let it happen.

So, how to generalize?
- honestly read Clean Code by C. Martin
- get to know Software Design Patterns
- practice

Don't spend much time overthinking it at the start.

Just start writing code and if you have a 'Déjà vu' moment it's just a matter of how many Déjà vus do you allow to happen until the technical debt emotionally blackmails you into refactoring.


### Benefits of using a universal structure


- The code is shareable between team mates because there is a universal standard which everyone should have agreed upon
- Easy to onboard on a new project which uses the already known standard
- Easy to spot and learn differences
- Reduce the cognitive burden of context switching
- Reduce the cost for finding a unique fit (hiring & solution wise)


## How to use as a flake


flake.nix:
```
{
  inputs = {

    # it's optional
    nixinate = {
      url = "github:matthewcroughan/nixinate";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-roleplay = {
      url = "github:rschardt/nix-roleplay";
    };
  };

  outputs = args @ { ... }: import ./outputs/outputs.nix args;
}
```

outputs.nix:
```
{
  self,
  ...
}:
let
  nix-roleplay = self.inputs.nix-roleplay.nix-roleplay {
    inherit self;
    src = ../.; # root path where nix-roleplay looks for nix-roleplay-dir, defaults to ./.
    nixOptions = [ "--impure" ]; # nixOptions passed to _module.args.nixinate, defaults to []
    # nix-roleplay-dir = "nix-rp"; # defaults to nix-rp
    # default_role # see ./nix-roleplay.nix, defaults to personal and nixinate_module
  };

in rec {
  nixosConfigurations = (nix-roleplay.func.create_nixos_configurations nix-roleplay.machines);
}
```

It is currently required to manually create the following directories at the src path which is used for iniializing nix-roleplay:
```
repository
├── nix-rp
│   ├── mod-categories.nix
│   └── roles.nix
│   ├── machines
│   │   ├── machines.nix
│   │   ├── machine_A
│   │   │   ├── nixos
│   │   │   │   ├── configuration.nix
│   │   │   │   ├── module-list.nix
│   ├── modules
│   │   ├── modules.nix
│   │   ├── module_A
│   │   │   ├── module-list.nix
```

In the following I will explain the directory and files.


### modules in modules directory


Those are automatically loaded via modules.nix inside the modules directory and available through the modules argument.


### modules.nix


The home of all your module imports.
See [Handling module imports as lambdas](#handling-module-imports-as-lambdas) for advanced ways of importing modules.

```
{
  self,
  ...
}:
{
  module_A = import ./module_A/module-list.nix
  module_B = import ./module_B/module-list.nix
  module_C = import ./module_C/module-list.nix
}
```

### configuration.nix


See https://nixos.org/manual/nixos/stable/


### module-list.nix


Only contains an array of paths pointing to different configurations.

```
[
  ./configuration.nix
]
```

### machines/machines.nix

Here do the machines live.

Add every machine which should be deployable through nixinate or other methods:

```
{
  self,
  roles,
  modules,
}:
[
  {
    name = "machine_A";
    roles = with roles.roles; role_A // role_B;
  }
  {
    name = "machine_B";
    roles = with roles.roles; role_B // role_C;
  }
  {
    name = "machine_C";
    roles = with roles.roles; role_C;

    # other attributes
    # system =
    # specialArgs =
    # pkgs =

    # alternative way to load modules directly
    extra_modules = with modules; [
      module_A
      module_B
      module_C
    ];
  }
]
```


#### Add new machines


- Add a new entry to the machines.nix in the machines directory.
- Create a directory with the machine's name in machines with the sub-folders/files shown above


### roles.nix


```
{
  self,
  modules,
  mod_categories,
  ...
}:
{
  roles = {
    role_A = {
      # other attributes
      # specialArgs =
      # system =
      # pkgs =
    };

    role_B = {
      pkgs = pkgsForClients common_system;
      mod_categories = with mod_categories.mod_categories; [
        mod_category_A
        mod_category_B
      ];

    };

    role_C = {
      mod_categories = with mod_categories.mod_categories; [
        mod_category_B
        mod_category_C
      ];

      # alternative way to import modules directly
      func_mods = with modules; [
        module_A
      ];
    };
  };
}
```


### mod_categories.nix


```
{
  modules,
  ...
}:
{
  mod_categories = {
    mod_category_A = {
      func_mods = [ modules.module_A ];
    };

    mod_category_B = {
      func_mods = [ modules.module_B ];
    };

    mod_category_C = {
      func_mods = with modules; [
        module_C
        module_A
      ];
    };
  };
}
```

### Using nixinate


When initializing nix-roleplay the default setting of the default_role attr sets _module_args_nixinate for every nixosConfiguration.

To overwrite this behaviour use the default_role attr.

Don't forget to add nixinate to inputs and outputs.apps as described [here](https://github.com/MatthewCroughan/nixinate).


### Using home-manager


This is an example modules.nix

```
{
  self,
  ...
}:
let
  home-manager = self.inputs.home-manager;
  merge = { path, name, home-manager }:
    (import (path + "/${name}" + /module-list.nix))
    ++ [
      home-manager.nixosModules.home-manager {
        imports = [
          (path + "/${name}" + /home-manager.nix) {}
        ];
      }
    ];
  mergeNormalWithHomeManagerImports = name:
    (merge {
      path = ./.;
      name = "${name}s";
      inherit home-manager;
    });
in
{
  module_swith_homemanager = mergeNormalWithHomeManagerImports "module_with_homemanager";
}
```


## Roadmap


### testing


Add testing with CI/CD and so on.


### add setup script for creating necessary directories/files


Add setup script to create nix-rp/{roles, mod_categories, modules, machines}


### nix-roleplay-collections


Flakehub esque:

* Collections of roles

* Collection of mod_categories

* Plugin system for collections of modules


### standardize module-list.nix for modules to remove modules.nix


### wrap home-manager utility code in a nix-roleplay.scripts attribute


### add more sections to table of contents


## Contact


If you also like nix/nixos feel free to follow me on github or connect via [Linkedin](https://www.linkedin.com/in/robert-schardt-539549127/)

Don't message me on linkedin regarding bugs, please create issues on github instead.
