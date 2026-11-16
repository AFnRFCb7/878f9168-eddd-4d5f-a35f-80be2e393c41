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
                                                                                        mounts =
                                                                                            {
                                                                                                out = { source = "$out" ; type = "bind" ; } ;
                                                                                            } ;
                                                                                        name = "package" ;
                                                                                        post = [ ] ;
                                                                                        runtime-inputs =
                                                                                            { config , ... } :
                                                                                                [
                                                                                                    nodejs
                                                                                                    pkgs.git
                                                                                                    (
                                                                                                        config.tree-serialization.explode
                                                                                                            {
                                                                                                                bytes = 1048576 ;
                                                                                                                input = "./node-modules" ;
                                                                                                                name = "explode" ;
                                                                                                                output = "./node-modules.exploded" ;
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
                                                                                                npm install "$NAME@$VERSION_SPECIFICATION"
                                                                                                explode
                                                                                                git rm node_modules
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