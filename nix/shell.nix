{ pkgs, db_name, MIX_ENV }:

with pkgs;
let
  elixir = beam.packages.erlangR24.elixir_1_12;
in
mkShell {
    buildInputs = [ git elixir rustc cargo mix2nix postgresql_13 ]
      ++ lib.optional stdenv.isLinux inotify-tools
      ++ lib.optionals stdenv.isDarwin
        (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);
    shellHook = ''
      # this allows mix to work on the local directory
      mkdir -p $PWD/.nix-mix
      mkdir -p $PWD/.nix-hex
      export MIX_HOME=$PWD/.nix-mix
      export HEX_HOME=$PWD/.nix-mix
      export PATH=$MIX_HOME/bin:$PATH
      export PATH=$HEX_HOME/bin:$PATH
      mix local.hex --if-missing
      export ERL_AFLAGS="-kernel shell_history enabled" 
      export MIX_ENV=${MIX_ENV};

      export PGDATA="$PWD/db"
      export POOL_SIZE=15
      export DB_NAME=${db_name}
      export DB_USER="postgres"
      export DB_PASSWORD="postgres"
      export DB_URL="ecto://$DB_USER:$DB_PASSWORD@localhost:5432/db"
      export PORT=4000
    '';
}