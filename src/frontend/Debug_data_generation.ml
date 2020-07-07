open Core_kernel
open Middle
open Ast

let rec transpose = function
  | [] :: _ -> []
  | rows ->
      let hd = List.map ~f:List.hd_exn rows in
      let tl = List.map ~f:List.tl_exn rows in
      hd :: transpose tl

let dotproduct xs ys =
  List.fold2_exn xs ys ~init:0. ~f:(fun accum x y -> accum +. (x *. y))

let matprod x y =
  let y_T = transpose y in
  if List.length x <> List.length y_T then
    failwith "Matrix multiplication dim. mismatch"
  else List.map ~f:(fun row -> List.map ~f:(dotproduct row) y_T) x

let rec vect_to_mat l m =
  let len = List.length l in
  if len % m <> 0 then
    failwith "the length has to be a whole multiple of the partition size"
  else if len = m then [l]
  else
    let hd, tl = List.split_n l m in
    hd :: vect_to_mat tl m

let unwrap_num_exn m e =
  let e = Ast_to_Mir.trans_expr e in
  let m = Map.Poly.map m ~f:Ast_to_Mir.trans_expr in
  let e = Analysis_and_optimization.Mir_utils.subst_expr m e in
  let e = Analysis_and_optimization.Partial_evaluator.eval_expr e in
  match e.pattern with
  | Lit (_, s) -> Float.of_string s
  | _ -> raise_s [%sexp ("Cannot convert size to number." : string)]

let unwrap_int_exn m e = Int.of_float (unwrap_num_exn m e)

let gen_num_int m t =
  let def_low, diff = (2, 4) in
  let low, up =
    match t with
    | Program.Lower e -> (unwrap_int_exn m e, unwrap_int_exn m e + diff)
    | Upper e -> (unwrap_int_exn m e - diff, unwrap_int_exn m e)
    | LowerUpper (e1, e2) -> (unwrap_int_exn m e1, unwrap_int_exn m e2)
    | _ -> (def_low, def_low + diff)
  in
  let low = if low = 0 && up <> 1 then low + 1 else low in
  Random.int (up - low + 1) + low

let gen_num_real m t =
  let def_low, diff = (2., 5.) in
  let low, up =
    match t with
    | Program.Lower e -> (unwrap_num_exn m e, unwrap_num_exn m e +. diff)
    | Upper e -> (unwrap_num_exn m e -. diff, unwrap_num_exn m e)
    | LowerUpper (e1, e2) -> (unwrap_num_exn m e1, unwrap_num_exn m e2)
    | _ -> (def_low, def_low +. diff)
  in
  Random.float_range low up

let rec repeat n e =
  match n with n when n <= 0 -> [] | m -> e :: repeat (m - 1) e

let rec repeat_th n f =
  match n with n when n <= 0 -> [] | m -> f () :: repeat_th (m - 1) f

let wrap_int n =
  { expr= IntNumeral (Int.to_string n)
  ; emeta= {loc= Location_span.empty; ad_level= DataOnly; type_= UInt} }

let int_two = wrap_int 2

let wrap_real r =
  { expr= RealNumeral (Float.to_string r)
  ; emeta= {loc= Location_span.empty; ad_level= DataOnly; type_= UReal} }

let wrap_row_vector l =
  { expr= RowVectorExpr l
  ; emeta= {loc= Location_span.empty; ad_level= DataOnly; type_= URowVector} }

let wrap_vector l =
  { expr= PostfixOp (wrap_row_vector l, Transpose)
  ; emeta= {loc= Location_span.empty; ad_level= DataOnly; type_= UVector} }

let gen_int m t = wrap_int (gen_num_int m t)
let gen_real m t = wrap_real (gen_num_real m t)

let gen_row_vector m n t =
  { expr= RowVectorExpr (repeat_th n (fun _ -> gen_real m t))
  ; emeta= {loc= Location_span.empty; ad_level= DataOnly; type_= UMatrix} }

let gen_vector m n t =
  let gen_ordered n =
    let l = repeat_th n (fun _ -> Random.float 1.) in
    let l =
      List.fold (List.tl_exn l) ~init:[List.hd_exn l] ~f:(fun accum elt ->
          (Float.exp elt +. List.hd_exn accum) :: accum )
    in
    l
  in
  match t with
  | Program.Simplex ->
      let l = repeat_th n (fun _ -> Random.float 1.) in
      let sum = List.fold l ~init:0. ~f:(fun accum elt -> accum +. elt) in
      let l = List.map l ~f:(fun x -> x /. sum) in
      wrap_vector (List.map ~f:wrap_real l)
  | Ordered ->
      let l = gen_ordered n in
      let halfmax =
        Option.value_exn (List.max_elt l ~compare:compare_float) /. 2.
      in
      let l = List.map l ~f:(fun x -> (x -. halfmax) /. halfmax) in
      wrap_vector (List.map ~f:wrap_real l)
  | PositiveOrdered ->
      let l = gen_ordered n in
      let max = Option.value_exn (List.max_elt l ~compare:compare_float) in
      let l = List.map l ~f:(fun x -> x /. max) in
      wrap_vector (List.map ~f:wrap_real l)
  | UnitVector ->
      let l = repeat_th n (fun _ -> Random.float 1.) in
      let sum =
        Float.sqrt
          (List.fold l ~init:0. ~f:(fun accum elt -> accum +. (elt ** 2.)))
      in
      let l = List.map l ~f:(fun x -> x /. sum) in
      wrap_vector (List.map ~f:wrap_real l)
  | _ -> {int_two with expr= PostfixOp (gen_row_vector m n t, Transpose)}

let gen_identity_matrix n m =
  { int_two with
    expr=
      RowVectorExpr
        (List.map
           (List.range 1 (n + 1))
           ~f:(fun k ->
             wrap_row_vector
               (List.map ~f:wrap_real
                  ( repeat (min (k - 1) m) 0.
                  @ (if k <= m then [1.0] else [])
                  @ repeat (m - k) 0. )) )) }

let gen_cov_matrix n m =
  let l = repeat_th (n * m) (fun _ -> Random.float 2.) in
  let l_mat = vect_to_mat l m in
  let cov = matprod l_mat (transpose l_mat) in
  let cov_wrapped =
    List.map ~f:wrap_row_vector
      (List.map ~f:(fun x -> List.map ~f:wrap_real x) cov)
  in
  {int_two with expr= RowVectorExpr cov_wrapped}

let gen_matrix mm n m t =
  match t with
  | Program.Covariance -> gen_cov_matrix n m
  | Program.CholeskyCorr | CholeskyCov | Correlation -> gen_identity_matrix n m
  | _ ->
      { int_two with
        expr= RowVectorExpr (repeat_th n (fun () -> gen_row_vector mm m t)) }

(* TODO: do some proper random generation of these special matrices *)

let gen_array elt n _ = {int_two with expr= ArrayExpr (repeat_th n elt)}

let rec generate_value m st t =
  match st with
  | SizedType.SInt -> gen_int m t
  | SReal -> gen_real m t
  | SVector e -> gen_vector m (unwrap_int_exn m e) t
  | SRowVector e -> gen_row_vector m (unwrap_int_exn m e) t
  | SMatrix (e1, e2) ->
      gen_matrix m (unwrap_int_exn m e1) (unwrap_int_exn m e2) t
  | SArray (st, e) ->
      let element () = generate_value m st t in
      gen_array element (unwrap_int_exn m e) t

let rec pp_value_json ppf e =
  match e.expr with
  | PostfixOp (e, Transpose) -> pp_value_json ppf e
  | IntNumeral s | RealNumeral s -> Fmt.string ppf s
  | ArrayExpr l | RowVectorExpr l ->
      Fmt.(pf ppf "[@[<hov 1>%a@]]" (list ~sep:comma pp_value_json) l)
  | _ -> failwith "This should never happen."

let var_decl_id d =
  match d.stmt with
  | VarDecl {identifier; _} -> identifier.name
  | _ -> failwith "This should never happen."

let var_decl_gen_val m d =
  match d.stmt with
  | VarDecl {decl_type= Sized sizedtype; transformation; _} ->
      generate_value m sizedtype transformation
  | _ -> failwith "This should never happen."

let print_data_prog s =
  let data = Option.value ~default:[] s.datablock in
  let l, _ =
    List.fold data ~init:([], Map.Poly.empty) ~f:(fun (l, m) decl ->
        let value = var_decl_gen_val m decl in
        ( l @ [(var_decl_id decl, value)]
        , Map.set m ~key:(var_decl_id decl) ~data:value ) )
  in
  let pp ppf (id, value) =
    Fmt.pf ppf {|@[<hov 2>"%s":@ %a@]|} id pp_value_json value
  in
  Fmt.(strf "{@ @[<hov>%a@]@ }" (list ~sep:comma pp) l)
