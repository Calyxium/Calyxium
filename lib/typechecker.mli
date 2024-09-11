(* typechecker.mli *)

module TypeChecker : sig
  module Env : sig
    type key = String.t
    type 'a t = 'a Map.Make(String).t

    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val update : key -> ('a option -> 'a option) -> 'a t -> 'a t
    val singleton : key -> 'a -> 'a t
    val remove : key -> 'a t -> 'a t

    val merge :
      (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t

    val union : (key -> 'a -> 'a -> 'a option) -> 'a t -> 'a t -> 'a t
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val for_all : (key -> 'a -> bool) -> 'a t -> bool
    val exists : (key -> 'a -> bool) -> 'a t -> bool
    val filter : (key -> 'a -> bool) -> 'a t -> 'a t
    val filter_map : (key -> 'a -> 'b option) -> 'a t -> 'b t
    val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
    val cardinal : 'a t -> int
    val bindings : 'a t -> (key * 'a) list
    val min_binding : 'a t -> key * 'a
    val min_binding_opt : 'a t -> (key * 'a) option
    val max_binding : 'a t -> key * 'a
    val max_binding_opt : 'a t -> (key * 'a) option
    val choose : 'a t -> key * 'a
    val choose_opt : 'a t -> (key * 'a) option
    val split : key -> 'a t -> 'a t * 'a option * 'a t
    val find : key -> 'a t -> 'a
    val find_opt : key -> 'a t -> 'a option
    val find_first : (key -> bool) -> 'a t -> key * 'a
    val find_first_opt : (key -> bool) -> 'a t -> (key * 'a) option
    val find_last : (key -> bool) -> 'a t -> key * 'a
    val find_last_opt : (key -> bool) -> 'a t -> (key * 'a) option
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
    val to_seq : 'a t -> (key * 'a) Seq.t
    val to_rev_seq : 'a t -> (key * 'a) Seq.t
    val to_seq_from : key -> 'a t -> (key * 'a) Seq.t
    val add_seq : (key * 'a) Seq.t -> 'a t -> 'a t
    val of_seq : (key * 'a) Seq.t -> 'a t
  end

  type func_sig = { param_types : Ast.Type.t list; return_type : Ast.Type.t }

  type class_info = {
    class_type : Ast.Type.t;
    properties : (string * Ast.Type.t) list;
  }

  type env = {
    var_type : Ast.Type.t Env.t;
    func_env : func_sig Env.t;
    class_env : class_info Env.t;
    modules : string list;
    exports : string list;
  }

  val empty_env : env
  (** Returns an empty environment. *)

  val lookup_var : env -> Env.key -> Ast.Type.t
  (** Looks up a variable's type in the environment.
      @param env The environment to look in.
      @param name The variable's name.
      @raise Failure if the variable is not found.
  *)

  val lookup_func : env -> Env.key -> func_sig
  (** Looks up a function's signature in the environment.
      @param env The environment to look in.
      @param name The function's name.
      @raise Failure if the function is not found.
  *)

  val lookup_class : env -> string -> class_info
  (** Looks up a class's information in the environment.
      @param env The environment to look in.
      @param name The class's name.
      @raise Failure if the class is not found.
  *)

  val check_import : env -> string -> env
  (** Checks if a module has been imported, updating the environment if not.
      @param env The current environment.
      @param module_name The name of the module to check.
      @return An updated environment with the module imported.
      @raise Failure if the module is already imported.
  *)

  val check_export : env -> Env.key -> env
  (** Checks if an identifier can be exported.
      @param env The current environment.
      @param identifier The identifier to export.
      @return An updated environment with the identifier added to exports.
      @raise Failure if the identifier is not defined.
  *)

  val check_expr : env -> Ast.Expr.t -> Ast.Type.t
  (** Recursively type checks an expression in the given environment.
      @param env The environment in which to type check the expression.
      @param expr The expression to check.
      @return The type of the expression.
      @raise Failure if the expression is invalid or has a type mismatch.
  *)

  val check_var_decl : env -> Env.key -> Ast.Type.t -> Ast.Expr.t option -> env
  (** Checks a variable declaration, ensuring its type matches the assigned value.
      @param env The current environment.
      @param identifier The name of the variable.
      @param explicit_type The declared type of the variable.
      @param assigned_value The value assigned to the variable, if any.
      @return An updated environment with the new variable.
      @raise Failure if there is a type mismatch or if no value is assigned.
  *)

  val check_func_decl :
    env ->
    Env.key ->
    Ast.Stmt.parameter list ->
    Ast.Type.t ->
    Ast.Stmt.t list ->
    env
  (** Recursively type checks a function declaration.
      @param env The current environment.
      @param name The function's name.
      @param parameters The function's parameters.
      @param return_type The function's return type.
      @param body The function's body (a block of statements).
      @return An updated environment with the function added.
      @raise Failure if there are type mismatches in the function body.
  *)

  val check_stmt :
    env -> expected_return_type:Ast.Type.t option -> Ast.Stmt.t -> env
  (** Type checks a statement, returning an updated environment.
      @param env The current environment.
      @param expected_return_type The expected return type of the statement, if any.
      @param stmt The statement to check.
      @return The updated environment.
      @raise Failure if the statement is invalid or has a type mismatch.
  *)

  val check_block :
    env -> Ast.Stmt.t list -> expected_return_type:Ast.Type.t option -> env
  (** Type checks a block of statements.
      @param env The current environment.
      @param stmts The list of statements to check.
      @param expected_return_type The expected return type of the block, if any.
      @return The updated environment.
  *)
end
