(** We show that presentable signatures generate a syntax
 *)

Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.Foundations.Sets.
(* Require Import UniMath.SubstitutionSystems.FromBindingSigsToMonads_Summary. *)
Require Import UniMath.SubstitutionSystems.BindingSigToMonad.
Require Import UniMath.SubstitutionSystems.Signatures.

Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.categories.HSET.All.

Require Import UniMath.CategoryTheory.functor_categories.

Require Import UniMath.CategoryTheory.Epis.
Require Import UniMath.CategoryTheory.EpiFacts.
Require Import Modules.Prelims.EpiComplements.
Require Import UniMath.Combinatorics.Lists.
Require Import UniMath.CategoryTheory.whiskering.
Require Import Modules.Prelims.lib.
Require Import Modules.Signatures.Signature.
Require Import Modules.Signatures.HssToSignature.
Require Import Modules.Signatures.BindingSig.
Require Import Modules.Signatures.EpiSigRepresentability.
Require Import Modules.Signatures.PreservesEpi.

Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.Monads.LModules. 
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.limits.coproducts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Open Scope cat.






Section PresentableDefinition.

Context {C : category} (bp : BinProducts C) (bcp : BinCoproducts C) (T : Terminal C)
          (cp : ∏ (I : hSet), Coproducts I C).

Let toSig sig  :=
  (BindingSigToSignature (homset_property C) bp bcp T  sig (cp (BindingSigIndexhSet sig))).


Definition isPresentable (a : signature C) :=
  ∑ (S : BindingSig) (F : signature_Mor (hss_to_ar (C := C) (toSig S)) a),
                            ∏ (R : Monad C), (isEpi (C := [_, _]) (pr1 (F R))).

End PresentableDefinition.


Section PresentableProjections.
  Context {C : category} {bp : BinProducts C} {bcp : BinCoproducts C} {T : Terminal C}
          {cp : ∏ (I : hSet), Coproducts I C}.


  Context {a : signature C} (p : isPresentable bp bcp T cp a).
Definition p_sig   : BindingSig := pr1 p.
Let toSig sig  :=
  (BindingSigToSignature (homset_property C) bp bcp T  sig (cp (BindingSigIndexhSet sig))).
Definition p_alg_ar   : signature C :=
  hss_to_ar (C := C) (toSig p_sig).

Definition p_mor : signature_Mor (p_alg_ar ) a := pr1 (pr2 p).
Definition epi_p_mor   : 
  ∏ (R : Monad C), (isEpi (C := [_, _]) (pr1 (p_mor  R)))
  := pr2 (pr2 p).


End PresentableProjections.

Local Notation hom_SET := has_homsets_HSET.
Local Notation Sig := (Signature SET has_homsets_HSET hset_precategory has_homsets_HSET).
Local Notation EndSet := [hset_category, hset_category].



Local Notation toSig sig :=
  (BindingSigToSignature has_homsets_HSET BinProductsHSET
                         BinCoproductsHSET TerminalHSET sig
                         (CoproductsHSET (BindingSigIndex sig) (BindingSigIsaset sig))).



Lemma PresentableisRepresentable 
      {a : signature SET} (p : isPresentable (C := SET) BinProductsHSET BinCoproductsHSET TerminalHSET
                                             (fun i => CoproductsHSET _ (setproperty i)) a)
      (** this hypothesis is implied by the axiom of choice
           It says that syntax of the presenting algebraic signature preserves epis.
       *)
      (alg_syntax_preserves_epi : preserves_Epi (alg_initialR (p_sig p) : model (p_alg_ar p)))

    (** this hypothesis is implied by the axiom of choice
           It says that the image of the (algebraic) syntax by the algebraic signature preserves epis.
       *)
      (alg_sig_syntax_preserves_epi : preserves_Epi ((p_alg_ar p) (alg_initialR (p_sig p) : model _)))


  :
   Initial (rep_disp SET) [{a}].
Proof.
  use (push_initiality_weaker (p_mor  p) _ _  ).
  - apply alg_initialR.
  - apply alg_syntax_preserves_epi.
  - apply ii1.
    apply alg_sig_syntax_preserves_epi.
  - apply epi_p_mor.
  - apply algSig_NatEpi.
  - apply algebraic_sig_representable.
Qed.

Lemma PresentableisRepresentable_choice
      {a : signature SET} (p : isPresentable (C := SET) BinProductsHSET BinCoproductsHSET TerminalHSET
                                             (fun i => CoproductsHSET _ (setproperty i)) a)
      (choice : AxiomOfChoice.AxiomOfChoice_surj)
  :
   Initial (rep_disp SET) [{a}].
Proof.
  use PresentableisRepresentable; (try apply preserves_to_HSET_isEpi); try assumption.
Qed.

