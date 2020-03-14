[@@@warning "-39"]
type t = {
  path_base: string; [@default "/"]

  definition_base: string;
  (** Prefix to be ignored in the OCaml module structure *)

  reference_base: string;
  (** Prefix to be ignored in Reference Objects *)

  reference_root: string;
  (** Submodule in which the code for Definition Objects will be created *)

  output: string; [@file] [@default "-"] [@aka ["o"]]
  (** Output file *)

  input: string; [@pos 0] [@file] [@docv "SPEC"]
  (** Swagger specification *)
} [@@deriving cmdliner]
[@@@warning "+39"]


let codegen {
  path_base;
  definition_base;
  reference_base;
  reference_root;
  output;
  input;
} =
  let output =
    if output = "-" then
      stdout
    else
      open_out output
  in
  let input =
    if input = "-" then
      stdin
    else
      open_in input
  in
  let open Swagger in
  Atdgen_runtime.Util.Json.from_channel Swagger_j.read_swagger input
  |> Gen.of_swagger
    ~path_base
    ~definition_base
    ~reference_base
    ~reference_root
  |> Gen.to_string
  |> Printf.fprintf output "%s\n"


let () =
  let open Cmdliner in
  let t =
    let doc = "Swagger 2.0 code generator for OCaml" in
    Term.(const codegen $ cmdliner_term ()),
    Term.info "swagger" ~doc
  in
  Term.(exit @@ eval t)
