{
    inputs = { } ;
    outputs =
        { self } :
            {
                lib =
                    { input ? x : x , output ? x : x } :
                        let
                            implementation =
                                { config , lib , pkgs , ... } @module :
                                    let
                                        identified = input module ;
                                        in
                                            with identified ;
                                                {
                                                    config.environment.sessionVariables.THE_ANSWER = config.lazy-node-packager { nodejs = pkgs.nodejs_22 ; } ;
                                                    options =
                                                        {
                                                            lazy-node-packager =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            { nodejs } :
                                                                                config.lazy-shell-application
                                                                                    {
                                                                                        mounts = { pwd = { source = "." ; type = "bind" ; } ; } ;
                                                                                        name = "package" ;
                                                                                        post = [ ] ;
                                                                                        runtime-inputs =
                                                                                            { config , ... } :
                                                                                                [
                                                                                                    nodejs
                                                                                                    pkgs.git
                                                                                                    (
                                                                                                        config.tree-serialization.explode ###
                                                                                                            {
                                                                                                                bytes = "1M" ;
                                                                                                                input = "/mounts/pwd/node_modules" ;
                                                                                                                name = "explode" ;
                                                                                                                output = "/mounts/pwd/node_modules.exploded" ;
                                                                                                            }
                                                                                                    )
                                                                                                ] ;
                                                                                        text =
                                                                                            ''
                                                                                                if [[ "$#" -ne 2 ]]
                                                                                                then
                                                                                                    failure 6437861303491491 "$@"
                                                                                                fi
                                                                                                NAME="$1"
                                                                                                VERSION_SPECIFICATION="$2"
                                                                                                git rm -r node_modules.exploded || rm -rf node_modules.exploded
                                                                                                git rm -r node_modules || rm -rf node_modules
                                                                                                npm install "$NAME@$VERSION_SPECIFICATION" --prefix "node_modules/$NAME@VERSION_SPECIFICATION"
                                                                                                explode
                                                                                                git rm -r node_modules || rm -rf node_modules
                                                                                                git add node_modules.exploded
                                                                                            '' ;
                                                                                        variables = { } ;
                                                                                    } ;
                                                                        type = lib.types.functionTo lib.types.package ;
                                                                    } ;
                                                        } ;
                                                } ;
                            in
                                {
                                    checks = null ;
                                    implementation = output implementation ;
                                    imports = null ;
                                } ;
            } ;
}