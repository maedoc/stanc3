open Core_kernel
open Middle
open Fmt

let is_multi_index = function Index.MultiIndex _ -> true | _ -> false

let pp_call ppf (name, pp_arg, args) =
  pf ppf "@[<hov 6>%s(@,%a@,)@]" name (list ~sep:comma pp_arg) args

let pp_call_str ppf (name, args) = pp_call ppf (name, string, args)
let pystring_of_operator = function x -> strf "%a" Operator.pp x

let rec pp_expr ppf {Expr.Fixed.pattern; _} =
  match pattern with
  | Var ident -> string ppf ident
  | Lit (Str, s) -> pf ppf "%S" s
  | Lit (Int, s) -> pf ppf "%s" s
  | Lit (_, s) -> pf ppf "tf__.cast(%s, dtype__)" s
  | FunApp (StanLib, f, obs :: dist_params)
    when String.is_prefix ~prefix:Transform_mir.dist_prefix f ->
      pf ppf "@[<hov 2>%a@,.log_prob(@,%a)@]" pp_call (f, pp_expr, dist_params)
        pp_expr obs
  | FunApp (StanLib, f, args) when Operator.of_string_opt f |> Option.is_some
  -> (
    match
      ( Operator.of_string_opt f |> Option.value_exn |> pystring_of_operator
      , args )
    with
    | op, [lhs; rhs] ->
        pf ppf "@[<hov2>(%a@ %s@ %a)@]" pp_expr lhs op pp_expr rhs
    | op, [unary] -> pf ppf "(%s%a)" op pp_expr unary
    | op, args ->
        raise_s [%message "Need to implement" op (args : Expr.Typed.t list)] )
  | FunApp (_, fname, args) -> pp_call ppf (fname, pp_expr, args)
  | TernaryIf (cond, iftrue, iffalse) ->
      pf ppf "%a if %a else %a" pp_expr cond pp_expr iftrue pp_expr iffalse
  | EAnd (a, b) -> pf ppf "%a and %a" pp_expr a pp_expr b
  | EOr (a, b) -> pf ppf "%a or %a" pp_expr a pp_expr b
  | Indexed (_, indices) when List.exists ~f:is_multi_index indices ->
      (*
       TF indexing options:
       * tf.slice
       * tf.gather
       * tf.gather_nd
       * tf.strided_slice
*)
      raise_s [%message "Multi-indices not supported yet"]
  | Indexed (obj, []) -> pp_expr ppf obj
  | Indexed (obj, indices) ->
      pf ppf "tf__.gather(%a, %a)" pp_expr obj
        (list ~sep:comma (Index.pp pp_expr))
        indices

(* Only necessary as long as we aren't inferring types, see
   https://github.com/stan-dev/stanc3/issues/373
*)
let pp_expr_int ppf e =
  match e.Expr.Fixed.pattern with
  | Lit (Int, s) | Lit (Real, s) -> string ppf s
  | _ -> pp_expr ppf e

let pp_method ppf name params intro ?(outro = []) ppbody =
  pf ppf "@[<v 2>def %a:@," pp_call_str (name, params) ;
  (list ~sep:cut string) ppf (intro @ [""]) ;
  ppbody ppf ;
  if not (List.is_empty outro) then pf ppf "@ %a" (list ~sep:cut string) outro ;
  pf ppf "@, @]"

let rec pp_stmt ppf s =
  let fake_expr pattern = {Expr.Fixed.pattern; meta= Expr.Typed.Meta.empty} in
  match s.Stmt.Fixed.pattern with
  | Assignment ((lhs, _, indices), rhs) ->
      let indexed = fake_expr (Indexed (fake_expr (Var lhs), indices)) in
      pf ppf "%a = %a" pp_expr indexed pp_expr rhs
  | TargetPE rhs ->
      pf ppf "@[<hov 2>target += tf__.reduce_sum(@,%a)@]" pp_expr rhs
  | NRFunApp (StanLib, f, args) | NRFunApp (UserDefined, f, args) ->
      pp_call ppf (f, pp_expr, args)
  | Break -> pf ppf "break"
  | Continue -> pf ppf "continue"
  | Return rhs ->
      pf ppf "return %a" (option ~none:(const string "None") pp_expr) rhs
  | Block ls | SList ls -> (list ~sep:cut pp_stmt) ppf ls
  | Skip -> ()
  (* | Decl {decl_adtype= AutoDiffable; decl_id; _} ->
   *     pf ppf "%s = tf.Variable(0, name=%S, dtype=np.float64)" decl_id decl_id *)
  | Decl _ -> ()
  | For {loopvar; lower; upper; body} ->
      let indexed_vars = ref [] in
      let rec pull_exprs_indexed_by i e =
        match e.Expr.Fixed.pattern with
        | Expr.Fixed.Pattern.Indexed
            (({pattern= Var vident; _} as obj), [Single {pattern= Var l; _}])
          when i = l ->
            indexed_vars := vident :: !indexed_vars ;
            obj
        | ep ->
            { e with
              pattern= Expr.Fixed.Pattern.map (pull_exprs_indexed_by i) ep }
      in
      let body =
        Stmt.Fixed.rewrite_bottom_up
          ~f:(pull_exprs_indexed_by loopvar)
          ~g:Fn.id body
      in
      let body_name = "body_" ^ Common.Gensym.generate () in
      pp_method ppf body_name ["body_vars__"]
        [ strf "@[<h>%a = body_vars__@]" (list ~sep:comma string)
            (!indexed_vars @ [loopvar])
        ; "target = 0" ]
        ~outro:["return target"]
        (fun ppf -> pp_stmt ppf body) ;
      pf ppf
        "@,@[<hov 2>target += tf__.reduce_sum(@,tf__.vectorized_map(%s, (%a, \
         tf__.range(%a, %a + 1))))@]"
        body_name (list ~sep:comma string) !indexed_vars pp_expr_int lower
        pp_expr_int upper
  | _ -> raise_s [%message "Not implemented" (s : Stmt.Located.t)]

let rec contains_int = function
  | SizedType.SArray (t, _) -> contains_int t
  | SInt -> true
  | _ -> false

let pp_cast prefix ppf (name, st) =
  match st with
  | SizedType.SInt | SReal -> pf ppf "%s%s" prefix name
  | _ ->
      pf ppf "tf__.convert_to_tensor(%s%s%s)" prefix name
        (if contains_int st then "" else ", dtype=dtype__")

let pp_init ppf p =
  let pp_save_data ppf (name, st) =
    pf ppf "self.%s = %a" name (pp_cast "") (name, st)
  in
  let ppbody ppf = (list ~sep:cut pp_save_data) ppf p.Program.input_vars in
  pp_method ppf "__init__" ("self" :: List.map ~f:fst p.input_vars) [] ppbody

let pp_extract_data ppf p =
  let pp_data ppf (name, _) = pf ppf "%s = self.%s" name name in
  (list ~sep:cut pp_data) ppf p.Program.input_vars

let pp_log_prob_one_chain ppf p =
  let pp_extract_param ppf (idx, name) =
    pf ppf "%s = tf__.cast(params[%d], dtype__)" name idx
  in
  let grab_params idx = function
    | name, {Program.out_block= Parameters; _} -> [(idx, name)]
    | _ -> []
  in
  let ppbody ppf =
    pf ppf "%a@,%a@,%a" pp_extract_data p
      (list ~sep:cut pp_extract_param)
      List.(concat (mapi p.output_vars ~f:grab_params))
      (list ~sep:cut pp_stmt) p.log_prob
  in
  let intro = ["target = 0"] in
  let outro = ["return target"] in
  pp_method ppf "log_prob_one_chain" ["self"; "params"] intro ~outro ppbody

let rec get_vident_exn e =
  match e.Expr.Fixed.pattern with
  | Var s -> s
  | Indexed (e, _) -> get_vident_exn e
  | _ -> raise_s [%message "No vident in" (e : Expr.Typed.t)]

let rec contains_var_expr is_vident accum {Expr.Fixed.pattern; _} =
  accum
  ||
  match pattern with
  | Var v when is_vident v -> true
  | _ -> Expr.Fixed.Pattern.fold (contains_var_expr is_vident) false pattern

let rec contains_var_stmt is_vident accum {Stmt.Fixed.pattern; _} =
  Stmt.Fixed.Pattern.fold
    (contains_var_expr is_vident)
    (contains_var_stmt is_vident)
    accum pattern

let get_param_st p var =
  let {Program.out_constrained_st= st; _} =
    List.Assoc.find_exn ~equal:( = ) p.Program.output_vars (get_vident_exn var)
  in
  st

let rec get_dims = function
  | SizedType.SInt | SReal -> []
  | SVector d | SRowVector d -> [d]
  | SMatrix (dim1, dim2) -> [dim1; dim2]
  | SArray (t, dim) -> dim :: get_dims t

let pp_log_prob ppf p =
  pf ppf "@ %a@ " pp_log_prob_one_chain p ;
  let intro =
    ["return tf__.vectorized_map(self.log_prob_one_chain, params)"]
  in
  pp_method ppf "log_prob" ["self"; "params"] intro (fun _ -> ())

let get_params p =
  List.filter
    ~f:(function _, {Program.out_block= Parameters; _} -> true | _ -> false)
    p.Program.output_vars

let pp_shapes ppf p =
  let pp_shape ppf (_, {Program.out_unconstrained_st; _}) =
    pf ppf "(nchains__, @[<hov>%a@])" (list ~sep:comma pp_expr)
      (get_dims out_unconstrained_st)
  in
  let ppbody ppf =
    pf ppf "%a@ " pp_extract_data p ;
    pf ppf "return [@[<hov>%a@]]" (list ~sep:comma pp_shape) (get_params p)
  in
  pp_method ppf "parameter_shapes" ["self"; "nchains__"] [] ppbody

let pp_bijector ppf trans =
  let pp_call_expr ppf (name, args) = pp_call ppf (name, pp_expr, args) in
  let components =
    match trans with
    | Program.Identity -> []
    | Lower lb -> [("Exp", []); ("AffineScalar", [lb])]
    | _ ->
        raise_s
          [%message
            "Unsupported " (trans : Expr.Typed.t Program.transformation)]
  in
  match components with
  | [] -> pf ppf "tfb__.Identity()"
  | ls ->
      pf ppf "tfb__.Chain([@[<hov>%a@]])"
        (list ~sep:comma pp_call_expr)
        List.(rev (map ls ~f:(fun (s, args) -> ("tfb__." ^ s, args))))

let pp_bijectors ppf p =
  let ppbody ppf =
    pf ppf "%a@ " pp_extract_data p ;
    pf ppf "return [@[<hov>%a@]]"
      (list ~sep:comma pp_bijector)
      (List.map ~f:(fun (_, {out_trans; _}) -> out_trans) (get_params p))
  in
  pp_method ppf "parameter_bijectors" ["self"] [] ppbody

let pp_param_names ppf p =
  let param_names =
    List.filter_map
      ~f:(function name, {out_block= Parameters; _} -> Some name | _ -> None)
      p.Program.output_vars
  in
  let ppbody ppf =
    pf ppf "return [@[<hov>%a@]]" (list ~sep:comma (fmt "%S")) param_names
  in
  pf ppf "@staticmethod@ " ;
  pp_method ppf "parameter_names" [] [] ppbody

let pp_methods ppf p =
  pf ppf "@ %a" pp_init p ;
  pf ppf "@ %a" pp_log_prob p ;
  pf ppf "@ %a" pp_shapes p ;
  pf ppf "@ %a" pp_bijectors p ;
  pf ppf "@ %a" pp_param_names p

let pp_fundef ppf {Program.fdname; fdargs; fdbody; _} =
  pp_method ppf fdname
    (List.map ~f:(fun (_, name, _) -> name) fdargs)
    []
    (fun ppf -> pp_stmt ppf fdbody)

let imports =
  {|
import numpy as np__
import tensorflow as tf__
import tensorflow_probability as tfp__
tfd__ = tfp__.distributions
tfb__ = tfp__.bijectors
dtype__ = tf__.float64
|}

let pp_prog ppf (p : Program.Typed.t) =
  pf ppf "%s@,@,%a@,class %s(tfd__.Distribution):@,@[<v 2>%a@]" imports
    (list ~sep:cut pp_fundef) p.functions_block p.prog_name pp_methods p ;
  pf ppf "@ model = %s" p.prog_name

(* Major work to do:
1. Work awareness of distributions and bijectors into the type system
2. Have backends present an environment that the frontend and middle can use for type checking and optimization.
*)
