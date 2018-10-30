Class CUClass {
    [String]$Name
    [ClassProperty[]]$Property
    [ClassConstructor[]]$Constructor
    [ClassMethod[]]$Method
    Hidden $Raw
    Hidden $Ast

    CUClass($RawAST){

        $this.Raw = $RawAST
        $this.Ast = $this.Raw.FindAll( {$args[0] -is [System.Management.Automation.Language.TypeDefinitionAst]}, $true)
        $This.SetPropertiesFromRawAST()

    }

    CUClass ($Name,$Property,$Constructor,$Method){

        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method

    }

    CUClass ($Name,$Property,$Constructor,$Method,$RawAST){

        $This.Name = $Name
        $This.Property = $Property
        $This.Constructor = $Constructor
        $This.Method = $Method
        $This.Raw = $RawAST

    }

    ## Set Name, and call Other Set
    [void] SetPropertiesFromRawAST(){

        $This.Name = $This.Ast.Name
        $This.SetConstructorFromAST()
        $This.SetPropertyFromAST()
        $This.SetMethodFromAST()

    }

    ## Find Constructors for the current Class
    [void] SetConstructorFromAST(){
        
        $Constructors = $null
        $Constructors = $This.Ast.Members | Where-Object {$_.IsConstructor -eq $True}

        Foreach ( $Constructor in $Constructors ) {

            $Parameters = $null
            $Parameters = $Constructor.Parameters
            [ClassProperty[]]$Paras = @()

            If ( $Parameters ) {
                
                Foreach ( $Parameter in $Parameters ) {

                    $Type = $null
                    # couldn't find another place where the returntype was located. 
                    # If you know a better place, please update this! I'll pay you beer.
                    $Type = $Parameter.Extent.Text.Split("$")[0] 
                    $Paras += [ClassProperty]::New($Parameter.Name.VariablePath.UserPath, $Type)
        
                }

            }

            $This.Constructor += [ClassConstructor]::New($Constructor.Name, $Constructor.ReturnType, $Paras,$Constructor)
        }

    }

    ## Find Methods for the current Class
    [void] SetMethodFromAST(){

        $Methods = $null
        $Methods = $This.Ast.Members | Where-Object {$_.IsConstructor -eq $False}

        Foreach ( $Method in $Methods ) {

            $Parameters = $null
            $Parameters = $Method.Parameters
            [ClassProperty[]]$Paras = @()

            If ( $Parameters ) {
                
                Foreach ( $Parameter in $Parameters ) {

                    $Type = $null
                    # couldn't find another place where the returntype was located. 
                    # If you know a better place, please update this! I'll pay you beer.
                    $Type = $Parameter.Extent.Text.Split("$")[0] 
                    $Paras += [ClassProperty]::New($Parameter.Name.VariablePath.UserPath, $Type)
        
                }

            }

            $This.Method += [ClassMethod]::New($Method.Name, $Method.ReturnType, $Paras,$Method)
        }

    }

    ## Find Properties for the current Class
    [void] SetPropertyFromAST(){

        $Properties = $This.Ast.Members | Where-Object {$_ -is [System.Management.Automation.Language.PropertyMemberAst]} 

        If ($Properties) {
        
            Foreach ( $Pro in $Properties ) {
                
                If ( $Pro.IsHidden ) {
                    $Visibility = "Hidden"
                } Else {
                    $visibility = "public"
                }
            
                $This.Property += [ClassProperty]::New($pro.Name, $pro.PropertyType.TypeName.Name, $Visibility,$Pro)
            }
        }

    }

    ## Return the content of Constructor
    [ClassConstructor[]]GetCuClassConstructor(){

        return $This.Constructor
        
    }

    ## Return the content of Method
    [ClassMethod[]]GetCuClassMethod(){

        return $This.Method

    }

    ## Return the content of Property
    [ClassProperty[]]GetCuClassProperty(){

        return $This.Property

    }

}