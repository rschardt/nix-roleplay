{
  self,
  src ? ./.,
  nix-roleplay-dir ? "nix-rp",
  nixOptions ? [],
  hostname ? "${name}",
  default_role ? {
    func_mods = [
      # personal_module
      (name: import (src + "/${nix-roleplay-dir}/machines/${name}/nixos/module-list.nix"))

      # TODO
      # Add dynamic import for home-manager.nix

      # nixinate_module
      (name: [
        {
          _module.args.nixinate = {
            host = "${hostname}";
            sshUser = "root";
            buildOn = "local";
            substituteOnTarget = false;
            hermetic = false;
            nixOptions = nixOptions;
          };
        }
      ])
    ];
  }
}:
rec {
  # default role is always included but overwriteable
  inherit default_role;
  nixpkgs = self.inputs.nixpkgs;

  modules = import (src + "/${nix-roleplay-dir}/modules/modules.nix") {
    inherit self;
  };

  roles = import (src + "/${nix-roleplay-dir}/roles.nix") {
    inherit self;
    inherit modules;
    inherit mod_categories;
  };

  machines = import (src + "/${nix-roleplay-dir}/machines/machines.nix") {
    inherit self;
    inherit modules;
    inherit roles;
  };

  mod_categories = import (src + "/${nix-roleplay-dir}/mod-categories.nix") {
    inherit modules;
  };

  nixosConfigurations = (func.create_nixos_configurations machines);

  func = {
    create_nixos_configurations = machines: let
      translate_configuration = prevNixConf: curNixConf @ {name, roles ? {}, ... }: let
        mergedAttrs = ((curNixConf.roles or {}) // curNixConf);
        merged_flattened_modules = ((curNixConf.roles.func_mods or [])
         ++ (merge_modules_in_baseRoles curNixConf)
         ### always included
         ++ (default_role.func_mods));
        merge_modules_in_baseRoles = args @ { roles ? {}, ... }: (if (builtins.hasAttr "mod_categories" (args.roles or {})) then
             builtins.foldl'
               (old: new:
                 (new.func_mods) ++ old
               )
               []
               (args.roles.mod_categories)
               else
                 []);
      in
      {
        "${curNixConf.name}" = nixpkgs.lib.nixosSystem { # replace * after '=' with '{' for debugging
          system = mergedAttrs.system;
          specialArgs = mergedAttrs.specialArgs;
          pkgs = mergedAttrs.pkgs;
          modules = nixpkgs.lib.lists.unique
            ((nixpkgs.lib.lists.flatten (curNixConf.extra_modules or []))
            ++ (apply_name_to_modules {
              name = curNixConf.name;
              modules = merged_flattened_modules;
            }));
        };
      } // prevNixConf;

      apply_name_to_modules = (args @ { name, modules, ... }: builtins.foldl'
        (a: b: let
          result = (if (builtins.typeOf b) == "lambda" then
              (b args.name)
            else
              b);
          in
            result ++ a)
        []
        args.modules);

    in
      builtins.foldl' translate_configuration {} machines;
  };
}
