{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    # Scripts runnable with nix run
    apps = let
      python = pkgs.python313;
      inherit (pkgs.lib) filterAttrs hasSuffix mapAttrsToList genAttrs;

      # App discovery and creation
      scriptsBasedir = ../scripts;
      scriptFiles = filterAttrs (name: type: type == "regular" && (hasSuffix ".sh" name || hasSuffix ".py" name)) (
        builtins.readDir scriptsBasedir
      );
      scriptNames = mapAttrsToList (name: _: pkgs.lib.removeSuffix ".sh" (pkgs.lib.removeSuffix ".py" name)) scriptFiles;

      # Build logic for creating executable scripts
      makeExecutable = scriptName: ''
        mkdir -p $out/bin
        if [ -f ${scriptsBasedir}/${scriptName}.sh ]; then
          cp ${scriptsBasedir}/${scriptName}.sh $out/bin/${scriptName}
        else
          cp ${scriptsBasedir}/${scriptName}.py $out/bin/${scriptName}
        fi
        chmod +x $out/bin/${scriptName}
        patchShebangs $out/bin/${scriptName}
      '';

      # Create individual apps
      makeScript = scriptName: {
        type = "app";
        program = "${pkgs.runCommand scriptName {buildInputs = [pkgs.bash python];} (makeExecutable scriptName)}/bin/${scriptName}";
        meta = {description = "Run ${scriptName}";};
      };
    in (genAttrs scriptNames makeScript);
  };
}
