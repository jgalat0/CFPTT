
Require Import List.

Set Implicit Arguments.


Section Exc_Type.

(* El tipo que representa al codominio de una funci\u00f3n parcial. *)
Inductive exc (V E : Set) : Set :=
  | Value : V -> exc V E
  | Error : E -> exc V E.


Variable V1 V2 V3 E1 E2 : Set.

Definition is_Value (e : exc V1 E1) : Prop :=
  match e with
  | Value _ => True
  | Error _ => False
  end.

End Exc_Type.


(* Descripci\u00f3n sencilla de los mappings, utilizando listas. *)

Notation "'If' c1 'then' c2 'else' c3" :=
  match c1 with
  | left _ => c2
  | right _ => c3
  end (at level 200).

Section Mapping_Definition.

(* El tipo de los \u00edndices para acceder a una entrada de un map *)
Variable index : Set.
Variable index_eq : forall x y : index, {x = y} + {x <> y}.

(* El tipo de la informaci\u00f3n asociada a cada \u00edndice *)
Variable info : Set.

Record item : Set := 
 Item
    (* \u00edndice*)
    {item_index : index;
    (* informaci\u00f3n asociada al \u00edndice *)
    item_info : info 
   }.

(* Mappings como listas *)
Definition mapping : Set := list item.

(* Map vac\u00edo  *)
Definition map_empty : mapping := nil.


(* Map add *)
(* Agrega una nueva entrada a un map. 
   Si la entrada ya existe, su informacion se redefine. *)

Fixpoint map_add (mp : mapping) (idx : index) 
  (inf : info) : mapping :=
  let newit := (Item idx inf) in 
  match mp with
  | nil =>  newit :: map_empty
  | it :: mp1 =>
      If index_eq (item_index it) idx
      then newit :: mp1 
      else it :: map_add mp1 idx inf
  end.

(* Map apply *)
(* Aplicaci\u00f3n de un map a un \u00edndice para obtener la informaci\u00f3n asociada 
a dicho \u00edndice *)

Fixpoint map_apply (mp : mapping) 
  (idx : index) : exc info index :=
  match mp with
  | nil => Error info idx
  | it :: mp1 =>
      If index_eq idx (item_index it) 
      then Value index (item_info it)
      else map_apply mp1 idx
  end.

(* Map drop *)
(* Elimina una entrada de un map *)
Fixpoint map_drop (mp : mapping) 
  (idx : index) : mapping :=
  match mp with
  | nil => nil 
  | it :: mp1 =>
      If index_eq idx (item_index it) 
      then map_drop mp1 idx
      else it :: map_drop mp1 idx
  end.
 
(* Observadores *)

Definition map_valid_index (mp : mapping) (idx : index) : Prop :=
  exists it : _, map_apply mp idx = Value index it.

Fixpoint map_valid_index_fix (mp:mapping) (idx:index) : bool :=
  match mp with
    | nil => false
    | it::mp' =>
      If (index_eq (item_index it) idx) then
        true
      else
        map_valid_index_fix mp' idx
  end.

(* Tama\u00f1o de un Map *)
Definition map_size (mp : mapping) : nat := length mp.

End Mapping_Definition.