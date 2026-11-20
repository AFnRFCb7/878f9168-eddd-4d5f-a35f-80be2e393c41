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
                                                    config.environment.sessionVariables.TEMPORARY1 = config.nodejs.fetchers.db-migrate ;
                                                    config.environment.sessionVariables.TEMPORARY2 = config.nodejs.fetchers.db-migrate-pg ;
                                                    options.nodejs =
                                                        {
                                                            fetch =
                                                                {
                                                                    default =
                                                                        { name , nodejs , version-spec } :
                                                                            config.nodejs.fetch
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
                                                                                                    config.tree-serialization.explode
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
                                                                                            if [[ "$#" -ne 0 ]]
                                                                                            then
                                                                                                failure 6437861303491491 ${ name } ${ nodejs } ${ version-spec }"$@"
                                                                                            fi
                                                                                            git rm -r node_modules.exploded || rm -rf node_modules.exploded
                                                                                            git rm -r node_modules || rm -rf node_modules
                                                                                            npm install "${ name }@${ version-spec }" --prefix "node_modules/${ nodejs }/${ name }/${ version-spec }"
                                                                                            explode
                                                                                            git rm -r node_modules || rm -rf node_modules
                                                                                            git add node_modules.exploded
                                                                                        '' ;
                                                                                    variables = { } ;
                                                                                } ;
                                                                    type = lib.types.functionTo lib.types.package ;
                                                                } ;
                                                            package =
                                                                lib.mkOption
                                                                    {
                                                                        default =
                                                                            { exploded } :
                                                                                pkgs.runCommand
                                                                                    "node-package"
                                                                                    {
                                                                                        nativeBuildInputs =
                                                                                            [
                                                                                                (
                                                                                                    config.tree-serialization.implode
                                                                                                        {
                                                                                                            input = "${ exploded }/node_modules.exploded" ;
                                                                                                            name = "implode" ;
                                                                                                            output = "$OUT" ;
                                                                                                        }
                                                                                                )
                                                                                            ] ;
                                                                                    }
                                                                                    ''
                                                                                        export OUT="$out"
                                                                                        implode
                                                                                    '' ;
                                                                        type = lib.types.functionTo lib.types.package ;
                                                                    } ;
                                                        } ;
                                                } ;
                            in
                                {
                                    check = null ;
                                    checks = null ;
                                    implementation = output implementation ;
                                    imports = null ;
                                } ;
            } ;
}