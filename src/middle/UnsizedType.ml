open Core_kernel
open Common.Helpers

type t = Mir_pattern.unsizedtype =
  | UInt
  | UReal
  | UVector
  | URowVector
  | UMatrix
  | UArray of t
  | UFun of (autodifftype * t) list * returntype
  | UMathLibraryFunction

and autodifftype = Mir_pattern.autodifftype = DataOnly | AutoDiffable

and returntype = Mir_pattern.returntype = Void | ReturnType of t
[@@deriving compare, hash, sexp]

let pp_autodifftype ppf = function
  | DataOnly -> pp_keyword ppf "data "
  | AutoDiffable -> ()

let unsized_array_depth unsized_ty =
  let rec aux depth = function
    | UArray ut -> aux (depth + 1) ut
    | ut -> (ut, depth)
  in
  aux 0 unsized_ty

let rec pp ppf = function
  | UInt -> pp_keyword ppf "int"
  | UReal -> pp_keyword ppf "real"
  | UVector -> pp_keyword ppf "vector"
  | URowVector -> pp_keyword ppf "row_vector"
  | UMatrix -> pp_keyword ppf "matrix"
  | UArray ut ->
      let ty, depth = unsized_array_depth ut in
      let commas = String.make depth ',' in
      Fmt.pf ppf "%a[%s]" pp ty commas
  | UFun (argtypes, rt) ->
      Fmt.pf ppf {|@[<h>(%a) => %a@]|}
        Fmt.(list pp_fun_arg ~sep:comma)
        argtypes pp_returntype rt
  | UMathLibraryFunction ->
      (pp_angle_brackets Fmt.string) ppf "Stan Math function"

and pp_fun_arg ppf (ad_ty, unsized_ty) =
  match ad_ty with
  | DataOnly -> Fmt.pf ppf {|data %a|} pp unsized_ty
  | _ -> pp ppf unsized_ty

and pp_returntype ppf = function
  | Void -> Fmt.string ppf "void"
  | ReturnType ut -> pp ppf ut

let uint = UInt
let ureal = UReal
let uvector = UVector
let urowvector = URowVector
let umatrix = UMatrix
let ufun args ty = UFun (args, ReturnType ty)
let ufun_void args = UFun (args, Void)
let umathlibfun = UMathLibraryFunction
let uarray uty = UArray uty

let autodifftype_can_convert at1 at2 =
  match (at1, at2) with DataOnly, AutoDiffable -> false | _ -> true

let check_of_same_type_mod_conv name t1 t2 =
  if String.is_prefix name ~prefix:"assign_" then t1 = t2
  else
    match (t1, t2) with
    | UReal, UInt -> true
    | UFun (l1, rt1), UFun (l2, rt2) ->
        rt1 = rt2
        && List.for_all
             ~f:(fun x -> x = true)
             (List.map2_exn
                ~f:(fun (at1, ut1) (at2, ut2) ->
                  ut1 = ut2 && autodifftype_can_convert at2 at1 )
                l1 l2)
    | _ -> t1 = t2

let rec check_of_same_type_mod_array_conv name t1 t2 =
  match (t1, t2) with
  | UArray t1elt, UArray t2elt ->
      check_of_same_type_mod_array_conv name t1elt t2elt
  | _ -> check_of_same_type_mod_conv name t1 t2

let check_compatible_arguments_mod_conv name args1 args2 =
  List.length args1 = List.length args2
  && List.for_all
       ~f:(fun y -> y = true)
       (List.map2_exn
          ~f:(fun sign1 sign2 ->
            check_of_same_type_mod_conv name (snd sign1) (snd sign2)
            && autodifftype_can_convert (fst sign1) (fst sign2) )
          args1 args2)

let is_real_type = function
  | UReal | UVector | URowVector | UMatrix
   |UArray UReal
   |UArray UVector
   |UArray URowVector
   |UArray UMatrix ->
      true
  | _ -> false

let is_int_type = function UInt | UArray UInt -> true | _ -> false
let is_fun_type = function UFun _ -> true | _ -> false

module Comparator = Comparator.Make (struct
  type nonrec t = t

  let compare = compare
  let sexp_of_t = sexp_of_t
end)

include Comparator

include Comparable.Make_using_comparator (struct
  type nonrec t = t

  let sexp_of_t = sexp_of_t
  let t_of_sexp = t_of_sexp

  include Comparator
end)