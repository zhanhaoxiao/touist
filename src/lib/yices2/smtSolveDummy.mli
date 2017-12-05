(** {b Requires [yices2]} Process an evaluated AST in order to solve
    it with Yices2. *)

val ast_to_yices :
  Touist.Types.AstSet.elt -> 'term * (string, 'term) Hashtbl.t

(** Turn a model into a string. *)
val string_of_model :
  ?value_sep:string ->
  (string, 'term) Hashtbl.t -> 'model -> string


(** [solve logic form] solves the Yices2 formula [form].
    [logic] can be "QF_LIA", "QF_LRA"...

    @see <http://yices.csl.sri.com/doc/smt-logics.html> Available logics
*)
val solve : string -> 'term -> 'model option

(** Tell if this logic string (e.g., QF_LIA) is supported by Yices2. *)
val logic_supported : string -> bool

(** Is this library enabled? (requires [yices2] to be installed) *)
val enabled : bool