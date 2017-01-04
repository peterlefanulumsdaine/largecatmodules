(*

In this file :


- Proof that HSET has effective epis

- Definition of a specific notion of equality (eq_diag) between
diagrams to circumvent the fact that axiom of functional extensionality
stops reduction with the standard equality.

- Various proofs about equals diagrams : they define the same limits/colimits.
This is used to switch between the pointwise definition of a diagram on vector
and the definition of the pointwise diagram.

- Definition of nat trans between diagrams (actually not really useful for
my goal : I rather use eq_diag)

- Proof that given a category D with pushouts, if a natural transformation 
between two functors of codomain D is an epi, then it is pointwise an epi 
(Colims_pw_epi).

- Proof that natural transformations that are effective epis are 
pointwise effective epis.

- Proof that a natural transformation which is an epi when the codomain of
considered functors is the hSet category has a lifting property similar
to the previously mentionned for surjections.

- Proof that if a natural transformation is pointwise epi, then
 any pre-whiskering of it is also an epi.


Section leftadjoint : 
Preuve d'André à traduire.

J'en suis à montrer que le μ de la représentation initiale candidate
vérifie bien le diagramme carré nécessaire. Mais Coq met trop de temps 
à calculer.

*)

Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.whiskering.

Require Import UniMath.CategoryTheory.Epis.

Require Import UniMath.CategoryTheory.Monads.
Require Import UniMath.CategoryTheory.RModules. 


Require Import TypeTheory.Auxiliary.Auxiliary.
Require Import TypeTheory.Auxiliary.UnicodeNotations.
Require Import TypeTheory.Displayed_Cats.Auxiliary.
Require Import TypeTheory.Displayed_Cats.Core.
Require Import TypeTheory.Displayed_Cats.Constructions.
Require Import TypeTheory.Displayed_Cats.Fibrations.

Require Import UniMath.CategoryTheory.HorizontalComposition.

Require Import UniMath.CategoryTheory.category_hset.
Require Import UniMath.CategoryTheory.category_hset_structures.
Require Import UniMath.CategoryTheory.limits.graphs.pullbacks.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.graphs.limits.
Require Import UniMath.CategoryTheory.limits.graphs.pushouts.
Require Import UniMath.CategoryTheory.limits.graphs.coequalizers.
Require Import UniMath.CategoryTheory.limits.pushouts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.kernels.
Require Import UniMath.CategoryTheory.limits.pullbacks.
Require Import UniMath.CategoryTheory.limits.coequalizers.



Require Import UniMath.CategoryTheory.CocontFunctors.



Local Notation "# F" := (functor_on_morphisms F)(at level 3).
Local Notation "F ⟶ G" := (nat_trans F G) (at level 39).
Local Notation "G □ F" := (functor_composite F G) (at level 35).
Local Notation "F ;;; G" := (nat_trans_comp _ _ _ F G) (at level 35).

(* Trouvé dans SubstitutionsSystem/Notation *)
Notation "α 'ø' Z" := (pre_whisker Z α)  (at level 25).
Notation "Z ∘ α" := (post_whisker α Z) (at level 50, left associativity).

(* En attendant que la pull request soit acceptée dans UniMaths 
Require Import Modules.Prelims.epis.
Require Import Modules.Prelims.sets.
Require Import Modules.Prelims.pushouts.
Require Import Modules.Prelims.effectiveepis.
Import Epis.
Import Basics.Sets.
Import limits.pushouts.

 *)
Require Import UniMath.CategoryTheory.limits.EffectiveEpis.
Require Import Modules.Prelims.ardef.
Require Import Modules.Prelims.quotientfunctor.





Section EquivPullbacks.
  Import graphs.pullbacks.

  (* wtf ? Il y a deux notions de pullback et je ne trouve pas le resultat suivant *)
  Definition equiv_Pullback {C:Precategory} {a b c  : C} {f : C ⟦b, a⟧} {g : C ⟦c, a⟧}
             (pb  : Pullback _ f g):
    limits.pullbacks.Pullback f g.
  Proof.
    intros.
    use  (limits.pullbacks.mk_Pullback _ _  (PullbackObject _ pb)
                                       (PullbackPr1 _ pb) (PullbackPr2 _ pb) ).
    apply PullbackSqrCommutes.
    abstract (
    apply equiv_isPullback_2;
    try apply isPullback_Pullback;
    apply homset_property).
  Defined.
End EquivPullbacks.

Section kernel_pair_Set.

  Local Notation SET := hset_Precategory.
  Context  {A B:SET}.
  Variable (f: SET ⟦A,B⟧).

  Lemma Pullbacks_HSET : Pullbacks SET.
    clear.
  Admitted.

  Definition kernel_pair_set : kernel_pair f.
    red.
    apply equiv_Pullback.
    apply LimsHSET_of_shape.
  Defined.

    
  Local Notation g := kernel_pair_set.

  Import limits.pullbacks.

  Lemma kernel_pair_eq
        (a:pr1 (PullbackObject g)) :
    f ( (PullbackPr1 g) a) = f ((PullbackPr2 g) a).
  Proof.
    intros.
    assert (hg':=PullbackSqrCommutes g).
    apply      toforallpaths in hg'.
    apply hg'.
  Qed.

  Lemma isCoeqEpi (hf:issurjective f) : isCoequalizer _ _ _ (PullbackSqrCommutes g).
  Proof.
    intros.
    red.
    intros C u equ.

    assert (hcompat :   Π x y : pr1 A, f x = f y → u x = u y).
    {
      intros x y eqfxy.
            assert (hpb:=pullback_HSET_univprop_elements
                     (PullbackSqrCommutes g) (isPullback_Pullback g) x y eqfxy).
      assert( hpb' := pr2 (pr1 hpb)); simpl in hpb'.
      destruct hpb' as [hx hy].
      
      etrans.
      symmetry.
      apply maponpaths.      
      apply hx.
      
      symmetry.
      etrans.
      symmetry.
      apply maponpaths.
      apply hy.
      
      apply toforallpaths in equ.
      symmetry.
      apply equ.
    }
    
    use (unique_exists (univ_surj (setproperty C) _ _ _ hf)).
    - exact u.
    - exact hcompat.
    - simpl.
      (* TODO parler à Benedikt : ici ça aurait été plus intéressatnd d'avoir une égalité dans univ_surj_ax *)
      apply funextfun.
      intros ?.
      apply univ_surj_ax.
    - intros ?; apply homset_property.
    - intros ??; simpl.
      apply funextfun.
      use univ_surj_unique.
      simpl in X.
      apply toforallpaths in X.
      exact X.
  Qed.
End kernel_pair_Set.




    



Lemma EffectiveEpis_HSET : EpisAreEffective hset_precategory.
Proof.
  red.
  clear.
  intros A B f epif.
  exists (kernel_pair_set f).
  apply isCoeqEpi.
  apply epiissurjectiontosets; [apply setproperty|].
  intros C g1 g2 h .
  apply toforallpaths.
  apply (epif C    g1 g2).
  now apply funextfun.
Qed.
    







(* The following section is copied from Pullback_pointwise section in limits/Pullbacks.v

Unfortunately, there is no such analogue in limits/Pushouts...

I am interested in showing that if D has colimits, then a colimit in the category [C,D] is
a colimit pointwise. I tried to derive this result from limits/graphs/colimits.v and the
construction of ColimitFunctors, however the pointwise diagrams seems to behave badly
(see tried example in the next section *)

Set Automatic Introduction.

      (** * Pushouts in functor categories *)
Section pushouts_pointwise.

(** Diagram for this section:
<<
          d
    J -------> H
    |          |
  c |          | b
    v          v
    G -------> F
         a
>>
 *)
Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).

Context {C D : precategory} (hsD : has_homsets D).
Let CD := [C, D, hsD].
Context {F G H J : CD}.
Context {a : CD ⟦G, F⟧}{b : CD ⟦H, F⟧}{c : CD⟦J,G⟧}{d : CD⟦J, H⟧}.

Variable Hcomm : c ;; a = d ;; b.

Arguments mk_Pushout {_ _ _ _ _ _ _ _ _ _ } _ .

Let Hcommx x := nat_trans_eq_pointwise Hcomm x.



Local Definition g (T : Π x, isPushout _ _ _ _ (Hcommx x))
      E (h : CD ⟦ G,E ⟧) (k : CD ⟦ H,E⟧)
      (Hhk : c;; h  = d ;; k ) : Π x, D ⟦ pr1 F x, pr1 E x ⟧.
Proof.

  intro x; apply (PushoutArrow (mk_Pushout (T x)) _ (pr1 h x) (pr1 k x)).
  abstract (apply (nat_trans_eq_pointwise Hhk)).
Defined.

Local Lemma is_nat_trans_g (T : Π x, isPushout _ _ _ _ (Hcommx x))
      E (h : CD ⟦ G, E ⟧) (k : CD ⟦ H, E ⟧)
      (Hhk :  c;; h  = d ;; k) : is_nat_trans _ _ (λ x : C, g T E _ _ Hhk x).
Proof.
  intros x y f; unfold g.
  apply (MorphismsOutofPushoutEqual (T x)).
  + rewrite !assoc, (PushoutArrow_PushoutIn1 (mk_Pushout (T x))).
    rewrite <- (nat_trans_ax a), <- assoc.
    now rewrite (PushoutArrow_PushoutIn1 (mk_Pushout (T y))), (nat_trans_ax h).
  + rewrite !assoc,(PushoutArrow_PushoutIn2 (mk_Pushout (T x))).
    rewrite <- (nat_trans_ax b), <- assoc.
    now rewrite (PushoutArrow_PushoutIn2 (mk_Pushout (T y))), (nat_trans_ax k).
Qed.

Lemma po_if_pointwise_po : (Π x, isPushout _ _ _ _ (Hcommx x)) ->
                           isPushout _ _ _ _ Hcomm.
Proof.
  intro T.
  use mk_isPushout; intros E h k Hhk.
  use unique_exists.
  - mkpair.
    + intro x; apply (g T E h k Hhk).
    + apply is_nat_trans_g.
  - abstract (split; apply (nat_trans_eq hsD); intro x;
              [ apply (PushoutArrow_PushoutIn1 (mk_Pushout (T x)))
              | apply (PushoutArrow_PushoutIn2 (mk_Pushout (T x))) ]).
  - abstract (intro; apply isapropdirprod; apply functor_category_has_homsets).
  - abstract (intros t [h1 h2]; destruct h as [h Hh];
              apply (nat_trans_eq hsD); intro x; apply PushoutArrowUnique;
              [ apply (nat_trans_eq_pointwise h1) | apply (nat_trans_eq_pointwise h2) ]).
Defined.



End pushouts_pointwise.

  Lemma is_exists_unique {A : UU} {B : A → UU} (H : ∃! a : A, B a) :
    B ( pr1 (iscontrpr1 H)).
  Proof.
    exact(pr2 (pr1 H)).
  Qed.


  Lemma transport_swap: Π {X Y : UU} (P : X -> Y → UU) {x x':X} {y  y' : Y} (e : x = x') (e' : y = y') (p : P x y),
                        transportf (fun a => P _ a) e' (transportf (fun a => P a _) e p) =
                        transportf (fun a => P a _) e (transportf (fun a => P _ a) e' p) .
    intros.
    destruct e.
    destruct e'.
    apply idpath.
  Qed.

  Definition eq_diag  {C : Precategory} {g : graph} (d d' : diagram g C) :=
    Σ (eq_v : Π v: vertex g, dob d v = dob d' v), Π (v v':vertex g) (f:edge v v'),
              transportf (fun obj => C⟦obj, dob d v'⟧)  (eq_v v) (dmor d f) =
              transportb (fun obj => C⟦_, obj⟧) (eq_v v') (dmor d' f).

  Lemma sym_eq_diag  {C : Precategory} {g : graph} (d d' : diagram g C) :
    eq_diag d d' -> eq_diag d' d.
  Proof.
    intros eq_d.
    set (eq_d1 := pr1 eq_d).
    set (eq_d2 := pr2 eq_d).

    use tpair.
    
    intro v.    
    apply (! (eq_d1 v)).
    cbn.
    intros v v' f.
    specialize (eq_d2 v v' f).
    symmetry.
    unfold transportb.
    rewrite pathsinv0inv0.
    apply (transportf_transpose (P:=(λ obj : C, C ⟦ obj, dob d' v' ⟧))).
    

    assert (eq_d2':=transportf_transpose (P:=(precategory_morphisms (dob d' v))) _ _ _ (! eq_d2)).
    rewrite eq_d2'.
    unfold transportb; rewrite pathsinv0inv0.
        apply (transport_swap (fun a b => C⟦b,a⟧)).
  Defined.

  Lemma eq_diag_mkcocone  :
    Π {C : Precategory} {g : graph} {d : diagram g C}       
      (d' : diagram g C)
      (heq_d: eq_diag d d')
    {c : C} (cc:cocone d c),
    cocone d' c.
  Proof.           
    clear.
    intros.
    destruct heq_d as [heq heq2].
    use mk_cocone.
    intro v.
    use (transportf (fun obj => C⟦obj,_⟧ ) (heq v)); simpl.
    apply (coconeIn cc).
    abstract(
    intros u v e; simpl;
    rewrite <- ( coconeInCommutes cc u v e);
    apply (pathscomp0 (b:=transportb (precategory_morphisms (dob d' u)) (heq v) (dmor d' e) ;; (coconeIn cc v)));
    [
    unfold transportb; (set (z:= ! heq v));
    rewrite <- (pathsinv0inv0 (heq v));
    symmetry;
    apply transport_compose|];

    etrans; [
    apply cancel_postcomposition;
    symmetry; apply heq2|];
    clear;
    now destruct (heq u)).
  Defined.

  (* inutile .. *)
  Lemma transportf_precompose : Π (C : precategory) (x y z w : C) (f : C ⟦ x, y ⟧) (g : C ⟦ y, z ⟧) (e : x = w), transportf (λ x' : C, C ⟦ x', z ⟧) e (f ;; g) = transportf (λ x' : C, C ⟦ x', y ⟧) e f ;; g.
    destruct e.
    apply idpath.
  Qed.



  
  (* same proof (dual= TODO : rewrite eq_diag_mkcocone better *)
  Lemma eq_diag_mkcone  :
    Π {C : Precategory} {g : graph} {d : diagram g C}       
      (d' : diagram g C)
      (heq_d: eq_diag d d')
    {c : C} (cc:cone d c),
    cone d' c.
  Proof.           
    clear.
    intros.
    (* apply sym_eq_diag in heq_d. *)
    set (heq := pr1 heq_d).
    set (heq2 := pr2 heq_d).
    use mk_cone.
    intro v.
    apply (transportf (fun obj => C⟦_,obj⟧ ) (heq v) (coneOut cc v)).
    
    abstract(
    intros u v e; simpl;

    
    rewrite <- ( coneOutCommutes cc u v e);
    etrans;[
    apply transport_compose|];
    rewrite transport_target_postcompose;
    apply cancel_precomposition;
    apply transportf_transpose;

    etrans;[
    apply (transport_swap (fun a b => C⟦a,b⟧))|];
    etrans;[
    apply maponpaths;
    symmetry;
    apply heq2|];
    apply (Utilities.transportbfinv  (λ a : C, C ⟦ a, dob d v ⟧) ) ).
  Defined.

  (* TODO refaire mieux en s'isnpirant de eq_diag_islimcone *)
  Lemma eq_diag_iscolimcocone:
    Π {C : Precategory} {g : graph} {d : diagram g C} 
      (d' : diagram g C)
      (eq_d : eq_diag d d')
            {c : C} {cc:cocone d c}
            (islimcone : isColimCocone _ _ cc) ,
    isColimCocone _ _ (eq_diag_mkcocone d' eq_d cc).
  Proof.

    intros.
    destruct eq_d as [eq_d1 eq_d2].
    set (eq_d := eq_d1,,eq_d2).
    set (eq_d'' := sym_eq_diag _ _ eq_d).
    set (eq_d1' := pr1 eq_d'').
    set (eq_d2' := pr2 eq_d'').
    set (eq_d'  := (eq_d1',,eq_d2'):eq_diag d' d).

    red.
    intros c' cc'.
    set (cc'2 := eq_diag_mkcocone _ eq_d' cc').
    specialize (islimcone c' cc'2).
    apply (unique_exists (pr1 (pr1 islimcone))).
    - intro v.
      assert (islim := is_exists_unique islimcone v).
      cbn in islim.
      cbn.

      etrans.
      rewrite <- (pathsinv0inv0 (eq_d1 v)).
      symmetry.
      apply transport_source_precompose.
      etrans.
      apply maponpaths.
      apply islim.
      cbn.
      now apply (Utilities.transportbfinv ( (λ x' : C, C ⟦ x', c' ⟧) )).
    - intro y.
      apply impred_isaprop.
      intro t.
      apply homset_property.
    - intros y hy.
      apply (path_to_ctr _ _ islimcone).
      intro v; specialize (hy v).
      revert hy.
      cbn.
      intro hy.
      apply (transportf_transpose (P:=(λ obj : C, C ⟦ obj, c' ⟧))).
      etrans.
      apply transport_source_precompose.      
      unfold transportb.
      rewrite pathsinv0inv0.
      apply hy.
  Qed.

  (* same proof : dual *)
  Lemma eq_diag_islimcone:
    Π {C : Precategory} {g : graph} {d : diagram g C} 
      (d' : diagram g C)
      (eq_d : eq_diag d d')
            {c : C} {cc:cone d c}
            (islimcone : isLimCone _ _ cc) ,
    isLimCone _ _ (eq_diag_mkcone d' eq_d cc).
  Proof.

    intros.
    set (eq_d1 := pr1 eq_d);
      set (eq_d2 := pr1 eq_d).
    set (eq_d' := sym_eq_diag _ _ eq_d).
    set (eq_d1' := pr1 eq_d').
    set (eq_d2' := pr2 eq_d').
    (* set (eq_d'  := (eq_d1',,eq_d2'):eq_diag d' d). *)

    red.
    intros c' cc'.
    set (cc'2 := eq_diag_mkcone _ eq_d' cc').
    specialize (islimcone c' cc'2).
    apply (unique_exists (pr1 (pr1 islimcone))).
    - intro v.
      assert (islim := is_exists_unique islimcone v).
      cbn in islim.
      cbn.

      etrans.
      symmetry.
      apply transport_target_postcompose.
      
      etrans.
      apply maponpaths.
      apply islim.

      apply Utilities.transportfbinv.

    - intro y.
      apply impred_isaprop.
      intro t.
      apply homset_property.
    - intros y hy.
      apply (path_to_ctr _ _ islimcone).
      intro v; specialize (hy v).
      cbn.
      apply transportf_transpose.
      rewrite <- hy.
      etrans.
      unfold transportb.
      rewrite pathsinv0inv0.
      apply transport_target_postcompose.
      apply idpath.
  Qed.

      

  Definition eq_diag_liftcolimcocone
    {C : Precategory} {g : graph} {d : diagram g C} 
      (d' : diagram g C)
      (eq_d : eq_diag d d')
       (cc:ColimCocone d ) : ColimCocone d'
    := mk_ColimCocone _ _ _ (eq_diag_iscolimcocone _ eq_d
                                               (isColimCocone_ColimCocone cc)).

  Definition eq_diag_liftlimcone
    {C : Precategory} {g : graph} {d : diagram g C} 
      (d' : diagram g C)
      (eq_d : eq_diag d d')
       (cc:LimCone d ) : LimCone d'
    := mk_LimCone _ _ _ (eq_diag_islimcone _ eq_d
                                               (isLimCone_LimCone cc)).


  
 

(* Definition of nat trans between diagrams *)
Section diagramNatTrans.

  Context {g:graph} {C:precategory} .

  Local Notation diag := (diagram g C).
  Local Notation "# F" := (dmor F)(at level 3).

  (* TODO cf colimOfArrows *)
  Definition is_diag_nat_trans {J J' : diag}
             (t : Π x : vertex g, dob J x -->  dob J' x) :=
    Π (x x' : vertex g)(f : edge x x'),
    # J f ;; t x' = t x ;; #J' f.


  Lemma isaprop_is_nat_trans (hs: has_homsets C) {J J' : diag}
        (t : Π x : vertex g, dob J x -->  dob J' x) :
    isaprop (is_diag_nat_trans t).
  Proof.
    repeat (apply impred; intro).
    apply hs.
  Qed. 
  
  Definition diag_nat_trans J J' :=
    total2 (fun t : Π x : vertex g, dob J x -->  dob J' x => is_diag_nat_trans t).

  Definition mk_diag_nat_trans {J J' }
             (t : Π x : vertex g, dob J x --> dob J' x)
             (H : is_diag_nat_trans  t) :
  diag_nat_trans J J' := tpair _ t H.

  Lemma isaset_diag_nat_trans  (hs: has_homsets C) J J'
   : isaset (diag_nat_trans J J').
  Proof.
    apply (isofhleveltotal2 2).
    + apply impred; intro t; apply hs.
    + intro x; apply isasetaprop, isaprop_is_nat_trans, hs.
  Qed.

  Definition diag_nat_trans_data  {J J' : diag}
           (a:diag_nat_trans J J') := pr1 a.
  Coercion diag_nat_trans_data : diag_nat_trans >-> Funclass.

  Definition diag_nat_trans_ax {J J' : diag}
             (a:diag_nat_trans J J') : is_diag_nat_trans a := pr2 a.


  (* Actually diagrams g -> C is a category but we just focus on the notion of
 iso *)
  Definition are_inverse {J J':diag} (a :diag_nat_trans J J')
    (b: diag_nat_trans J' J):=
    ( Π v:vertex g, a v ;; b v = identity _)
      ×  Π v:vertex g, b v ;; a v = identity _ .


  
  
End diagramNatTrans.



(* a transfo nat between two diagrams induces a lift of cocones *)
Section liftCocone.

  Context {g:graph} {C:precategory} {J J' : diagram g C}.
  Context (m:diag_nat_trans J J') {c:C} .

  Definition lift_cocone (cc: cocone J' c) : cocone J c.
    assert (h := coconeInCommutes cc).
    set (fin := (coconeIn cc)) in *.

    apply (mk_cocone(fun v => m v ;; fin v)).
        abstract(
    intros u v e;
    rewrite assoc, (diag_nat_trans_ax m), <- assoc, h; apply idpath).
  Defined.

  Definition lift_cone (cc: cone J c): cone J' c.
    assert (h := coneOutCommutes cc).
    set (fin := (coneOut cc)) in *.

    apply (mk_cone(fun v =>  fin v;; m v)).
    abstract(
    intros u v e;    
    rewrite <- assoc, <- (diag_nat_trans_ax m), assoc, h; apply idpath).
  Defined.

End liftCocone.

Section isoCocone.

  Context {g:graph} {C:precategory} {J J' : diagram g C}.



  Section isCone.
      Context  {c:C}.
      Lemma iso_colimCocone   (cc: cocone J' c) (hs:has_homsets C) {a b}
            (hinv:are_inverse (J:=J) (J':=J') a b)  :
        isColimCocone J' c cc -> isColimCocone J c (lift_cocone a cc).
      Proof.
        intros iscolim c' cc'.
        specialize (iscolim c' (lift_cocone b cc')).
        apply (unique_exists (pr1 (pr1 iscolim))).
        - intro v.
          cbn.
          etrans.
          rewrite <- assoc.
          apply cancel_precomposition.
          apply (is_exists_unique iscolim v).
          cbn.
          rewrite assoc,(pr1 hinv).
          apply id_left.
        - intros y.
          apply impred_isaprop.
          intros; apply hs.
        - intros y hy.
          apply (eq_exists_unique _ _ iscolim).
          intro v; specialize (hy v).
          cbn in hy; cbn.
          rewrite <- hy, assoc, assoc, (pr2 hinv), id_left.
          apply idpath.
      Qed.

      Lemma iso_colimCocone'   (cc: cocone J' c) (hs:has_homsets C) {a b} (hinv:are_inverse (J:=J) (J':=J') a b)  :
        isColimCocone J c (lift_cocone a cc) -> isColimCocone J' c cc.
      Proof.
        intros iscolim c' cc'.
        specialize (iscolim c' (lift_cocone a cc')).
        apply (unique_exists (pr1 (pr1 iscolim))).
        - intro v.
          cbn.
          assert (hv:= (is_exists_unique iscolim v)).
          cbn in hv.
          assert (hv':=cancel_precomposition _ _ _ _ _ _ (b v) hv).
          revert hv'.
          repeat rewrite assoc.
          now rewrite (pr2 hinv),id_left,id_left.
        - intros y.
          apply impred_isaprop.
          intros; apply hs.
        - intros y hy.
          apply (eq_exists_unique _ _ iscolim).
          intro v; specialize (hy v).
          cbn in hy; cbn.
          now rewrite <- assoc, hy.
      Qed.

  (* The proof could be simpler using the duality between limits and colimits
but I did not find any proof in UniMath that limits are colimits in the dual category *)
  Lemma iso_limCone   (cc: cone J c) (hs:has_homsets C) {a b} (hinv:are_inverse (J:=J) (J':=J') a b)  :
    isLimCone J c cc -> isLimCone J' c (lift_cone a cc).
  Proof.
        intros iscolim c' cc'.
    specialize (iscolim c' (lift_cone b cc')).
    apply (unique_exists (pr1 (pr1 iscolim))).
    - intro v.
      cbn.
      etrans.
      rewrite assoc.
      apply cancel_postcomposition.
      apply (is_exists_unique iscolim v).
      cbn.
      rewrite <- assoc,(pr2 hinv).
      apply id_right.
    - intros y.
      apply impred_isaprop.
      intros; apply hs.
    - intros y hy.
      apply (eq_exists_unique _ _ iscolim).
      intro v; specialize (hy v).
      cbn in hy; cbn.
      rewrite <- hy, <- assoc, <- assoc, (pr1 hinv), id_right.
      apply idpath.
  Qed.
  End isCone.

  Lemma iso_liftlimCone (hs:has_homsets C) {a b} (hinv:are_inverse (J:=J) (J':=J') a b) :
    LimCone J -> LimCone J'.
  Proof.
    intros cc.
    use mk_LimCone; cycle 2.
    use (iso_limCone (limCone cc) hs hinv).
    apply isLimCone_LimCone .
  Defined.
  
  Lemma iso_liftcolimCocone (hs:has_homsets C) {a b} (hinv:are_inverse (J:=J) (J':=J') a b) :
    ColimCocone J' -> ColimCocone J.
  Proof.
    intros cc.
    use mk_ColimCocone; cycle 2.
    use (iso_colimCocone (colimCocone cc) hs hinv).
    apply isColimCocone_ColimCocone .
  Qed.    


End isoCocone.

(* used as admit when Qed takes too long *)
Lemma toolong : forall A, A.
Admitted.                       

(*
  (* Exclusive lemma : the converse *)
Lemma pointwise_po_if_po (hpo :Pushouts D) :   isPushout _ _ _ _ Hcomm ->
                                               (Π x, isPushout _ _ _ _ (Hcommx x)).
Proof.
  intros T x.
  assert (pocd := (hpo _ _ _ (pr1 c x) (pr1 d x))).
  set (pocd2 := isPushout_Pushout pocd).
  use mk_isPushout; intros E h k Hhk.
  use unique_exists.
  - mkpair.
    + intro x; apply (g T E h k Hhk).
    + apply is_nat_trans_g.
  - abstract (split; apply (nat_trans_eq hsD); intro x;
              [ apply (PushoutArrow_PushoutIn1 (mk_Pushout (T x)))
              | apply (PushoutArrow_PushoutIn2 (mk_Pushout (T x))) ]).
  - abstract (intro; apply isapropdirprod; apply functor_category_has_homsets).
  - abstract (intros t [h1 h2]; destruct h as [h Hh];
              apply (nat_trans_eq hsD); intro x; apply PushoutArrowUnique;
              [ apply (nat_trans_eq_pointwise h1) | apply (nat_trans_eq_pointwise h2) ]).
Defined.
*)

(* if colimits are computed pointwise, then a transfo nat which is an epi is
 pointwise an epi*)

Section PointwiseEpi.


  Definition functor_Precategory (C:precategory) (D:Precategory) : Precategory :=
    (functor_precategory C D (homset_property D),,
                         functor_category_has_homsets _ _ _).

  Context { C :precategory} {D:Precategory} .

  Local Notation CD := (functor_precategory C D (homset_property D)).
  Local Notation CD_Pre := (functor_Precategory C D).


  (* transfo nat between pushouts pw and pushout in D *)
      (* Finalement inutile avec les puissants lemmes de transport 
 eq_diag_liftlimcone
  Section pushouts.
    Context {X Y Z :CD} {a:CD  ⟦ X, Y ⟧} {b:CD ⟦ X, Z⟧} (x:C).
    Local Notation poD := (pushout_diagram D (pr1 a x) (pr1 b x)).
    Local Notation po_pw := ((diagram_pointwise (homset_property D)
                                                (pushout_diagram CD a b) x) ).

    Definition poD_to_pw_data :  Π v : vertex _, dob poD v -->  dob po_pw v.
      use StandardFiniteSets.three_rec_dep;simpl; apply identity.
    Defined.

    Definition pw_to_poD_data : Π v : vertex _, dob po_pw v -->  dob poD v.
      use StandardFiniteSets.three_rec_dep;simpl; apply identity.
    Defined.

    Lemma is_nat_trans_poD_to_pw : is_diag_nat_trans poD_to_pw_data.
      use StandardFiniteSets.three_rec_dep;
        use StandardFiniteSets.three_rec_dep;
        try exact (Empty_set_rect _ );
      cbn;
        unfold idfun; simpl;
      now rewrite id_left, id_right.
    Qed.

    Lemma is_nat_trans_pw_to_poD : is_diag_nat_trans pw_to_poD_data.
    Proof.
      use StandardFiniteSets.three_rec_dep;
        use StandardFiniteSets.three_rec_dep;
        try exact (Empty_set_rect _ );
      cbn;
        unfold idfun; simpl;
      now rewrite id_left, id_right.
    Qed.      

    Definition pw_to_poD : diag_nat_trans po_pw poD :=
      mk_diag_nat_trans _ is_nat_trans_pw_to_poD.

    Definition poD_to_pw : diag_nat_trans poD po_pw :=
      mk_diag_nat_trans _ is_nat_trans_poD_to_pw.


    Lemma is_inv_pw_poD : are_inverse pw_to_poD poD_to_pw.
    Proof.
      split; use StandardFiniteSets.three_rec_dep; apply id_left.
    Qed.

  End pushouts.
*)

  (* A colimit is a colimit pointwise *)
  Lemma pw_colim
        (g:graph) (J:diagram g CD)
        (colimD: Π a : C, ColimCocone
                 (diagram_pointwise (homset_property D) J a))
(F:CD) (R:cocone J F) :
    isColimCocone J F R ->
    Π c : C,
          isColimCocone (diagram_pointwise  (homset_property _)  J c) (pr1 F c)
                        (cocone_pointwise  (homset_property _)  J F R c).
  Proof.
    intros  isColim c.
    apply isColimFunctor_is_pointwise_Colim.
    intros b; apply colimD.
    assumption.
  Qed.

  Lemma cocone_pushout_pw {X Y Z :CD} {a:CD  ⟦ X, Y ⟧} {b:CD ⟦ X, Z⟧} {x c}
        (cc : cocone (pushout_diagram D (pr1 a x) (pr1 b x))  c) :
    cocone
      (diagram_pointwise (homset_property D)
                         (pushout_diagram CD a b) x) c.
  Proof.
    simple refine (mk_cocone _ _  ).
    -
    intro v.
    specialize (pr1 cc v).
    pattern v.
   
    use StandardFiniteSets.three_rec_dep;simpl; apply idfun.

    -      
    intros u v e;
     specialize (pr2 cc u v e);
     revert u v e;
     use StandardFiniteSets.three_rec_dep;  use StandardFiniteSets.three_rec_dep; 
        exact (Empty_set_rect _ ) || (exact (fun v h => h)).
  Defined.

  Import graphs.pushouts.
  Lemma Colims_pw_epi (colimD : Pushouts D) (A B : CD) (a:CD⟦ A,B⟧)
        (epia:isEpi a) : Π (x:C), isEpi (pr1 a x).
  Proof.    
    intro  x; simpl.
    apply (epi_to_pushout (C:=CD_Pre)) in epia.
    apply pushout_to_epi.
    simpl.
    apply equiv_isPushout1 in epia; [| apply homset_property].
    apply equiv_isPushout2; [ apply homset_property|].

    red in epia.
    red.
    
    
    apply pw_colim with (c:=x) in epia ; cycle 1.
    {
      intro c.
      
      unfold Pushouts in colimD.
      specialize (colimD _ _ _ (pr1 a c) (pr1 a c)).
      red in colimD.
      use( eq_diag_liftcolimcocone _ _ colimD) . 
      use tpair.
      use StandardFiniteSets.three_rec_dep; apply idpath.
      use StandardFiniteSets.three_rec_dep;  use StandardFiniteSets.three_rec_dep; 
         exact (Empty_set_rect _ )||exact (fun _ => idpath _).
    }

    intros c cc.
    specialize (epia c (cocone_pushout_pw cc)).
    apply (unique_exists (pr1 (iscontrpr1 epia))).

    - assert (hepi := pr2 (iscontrpr1 epia)); simpl in hepi.
      intro v.
      generalize v (hepi v).
      use StandardFiniteSets.three_rec_dep; intro h; apply h.
    - intros y.
      apply impred_isaprop.
      intros t.
      apply homset_property.
    - assert (hepi2 := eq_exists_unique _ _ epia); simpl in hepi2.
      intros y hv; specialize (hepi2 y).
      apply hepi2.
      intros v; specialize (hv v).
      revert v hv.
      use StandardFiniteSets.three_rec_dep;intro h; apply h.
  Qed.

End PointwiseEpi.



(* Let f be a transfo nat. If f is pointwise effective, then f is effective *)
Section IsEffectivePw.
  
    Context { C :precategory} {D:Precategory} .

    

   Local Notation CD := (@functor_Precategory C D). 

   
    Context {X Y :functor C D } {a:CD ⟦X,Y⟧}.

  Lemma isEffectivePw : (Π (x:C), isEffective (pr1 a x)) -> isEffective a.
    intros h.
    red.
    transparent assert (f:(kernel_pair a)).
    { apply equiv_Pullback_2;[apply homset_property|].
      apply LimFunctorCone.
      intro c.
      specialize (h c).
      set (f := pr1 h).
      apply equiv_Pullback_1 in f;[|apply homset_property].
      use (eq_diag_liftlimcone _  _  f).
      use tpair.
      use StandardFiniteSets.three_rec_dep; apply idpath.
      
      use StandardFiniteSets.three_rec_dep;  use StandardFiniteSets.three_rec_dep; 
         exact (Empty_set_rect _ ) ||  (exact (fun _ => idpath _)).
    }

    exists f.


    apply equiv_isCoequalizer2;[apply homset_property|].
    apply  pointwise_Colim_is_isColimFunctor.
    intro x.
    set (g:= f).
    assert (hf := (pr2 (h x))); simpl in hf.
    apply equiv_isCoequalizer1 in hf;[|apply homset_property].
    red in hf.
    
    revert hf.
    match goal with |- isColimCocone ?d1 _ ?cc1 -> isColimCocone  ?d2 _  ?cc2 =>
                    transparent assert (eqd:(eq_diag d1 d2)) end.
    {
      use tpair.
      use StandardFiniteSets.two_rec_dep; reflexivity.
     use StandardFiniteSets.two_rec_dep;  use StandardFiniteSets.two_rec_dep; 
       try exact (Empty_set_rect _ ).

     intros g'.
     destruct g'.
     apply idpath.
     apply idpath.
    } 

    intro hf.

    set (z:= (eq_diag_iscolimcocone _ eqd hf)).
    set (CC := (mk_ColimCocone _ _ _ z)).
    apply (is_iso_isColim (homset_property D) _ CC).
    rewrite <- (colimArrowUnique CC _ _ (identity _)).
    
    apply identity_is_iso.
    use StandardFiniteSets.two_rec_dep;
    cbn beta;

    rewrite id_right;
    apply idpath.
Qed.


  
End IsEffectivePw.


(* 

 Preuve qu'on peut relever les épi dans la catégorie des endo foncteurs sur Set
Autrement dit :
    f
 A ---> C
 |
 | p
 |
 \/
 B

Si p est un épi et que pour tout x y dans A, p(x)=p(y) => f(x)=f(b)
alors il existe une unique flèche de B vers C qui complète le diagramme.

Ca vient du fait que les epis sont effectifs

*)
Section LiftEpiNatTrans.
  
  Local Notation SET := hset_Precategory.
  Context { Cat:precategory}.
  Local Notation "[ C , D , hs ]" := (functor_precategory C D hs).
  Local Notation C_SET :=  ([Cat, SET, (homset_property SET)]).

  Context {A B C:C_SET} (p:nat_trans (pr1 A) (pr1 B))
          (f:nat_trans (pr1 A)(pr1 C)).

  Hypothesis (comp_epi: Π (X:Cat)  (x y: pr1 (pr1 A X)),
                        p X x =  p X y -> f X x = f X y).


  Hypothesis (surjectivep : isEpi (C:=C_SET) p).

  Import graphs.pushouts.

  Lemma PushoutsHSET : Pushouts SET.
    red.
    intros .
    apply ColimsHSET_of_shape.
  Qed.

  Lemma EffectiveEpis_Functor_HSET : EpisAreEffective C_SET.
  Proof.
    intros F G m isepim.
    apply isEffectivePw.
    intro x.
    apply EffectiveEpis_HSET.
    apply (Colims_pw_epi PushoutsHSET).
    assumption.
  Qed.
    
  Definition univ_surj_nt :nat_trans ( (pr1 B )) ( (pr1 C )).

    apply EffectiveEpis_Functor_HSET in surjectivep.
    red in surjectivep.
    set (coeq := limits.coequalizers.mk_Coequalizer _ _ _ _ (pr2 surjectivep)).
    apply (limits.coequalizers.CoequalizerOut coeq _ f).
    abstract(
    apply (nat_trans_eq (homset_property _));
    intro c;
    apply funextfun;
    intro x;
    apply comp_epi;
    assert (hcommut := limits.pullbacks.PullbackSqrCommutes (pr1 surjectivep));
    eapply nat_trans_eq_pointwise in hcommut;
    apply toforallpaths in hcommut;
    apply hcommut).
  Defined.

  Import limits.coequalizers.

  Lemma univ_surj_nt_ax : ( p  ;;; univ_surj_nt   )   = f .
  Proof.
    unfold univ_surj_nt; cbn.
    set (coeq := mk_Coequalizer _ _ _ _ _).
    apply (CoequalizerCommutes coeq).
  Qed.

  Lemma univ_surj_nt_ax_pw x  : ( p x ;; univ_surj_nt x  )    = f x .
  Proof.
    now rewrite <- univ_surj_nt_ax.
  Qed.

  
  Lemma univ_surj_nt_ax_pw_pw x c : ( p x ;; univ_surj_nt x  ) c   = f x c.
  Proof.
    now rewrite <- univ_surj_nt_ax.
  Qed.

End LiftEpiNatTrans.

Lemma is_pointwise_epi_from_set_nat_trans_epi (C:precategory)
      (F G : functor C hset_Precategory) (f:nat_trans ( F) ( G))
      (h:isEpi (C:=functor_Precategory C hset_Precategory) f)
  : Π (x:C), isEpi (f x).
Proof.
  apply Colims_pw_epi.
  apply PushoutsHSET.
  apply h.
Qed.



  Lemma isEpi_pre_whisker (B C :precategory)( D:Precategory)
         (G H : functor C D) ( K : functor B C) (f:nat_trans G H)
    : (Π x, isEpi (* (C:= functor_Precategory _ _) *) (f x)) -> isEpi (C:=functor_Precategory B D )
                                                    (x:= (G □ K)) (y:= (H □ K))
                                                    (pre_whisker K f).
  Proof.
    clear.
    intro isEpif.
    apply is_nat_trans_epi_from_pointwise_epis.
    intro a.
    apply isEpif.
  Qed.
  
(* This is true for finitary endofunctors
or assuming the axiom of choice
 *)
  Lemma isEpi_post_whisker (B :precategory)(C D:Precategory)
         (G H : functor B C) ( K : functor C D) (f:nat_trans G H)
    : isEpi (C:= functor_Precategory _ _) f
      -> isEpi (C:=functor_Precategory B D)
              (x:= (K □ G)) (y:= (K □ H))
              (post_whisker f K).
  Proof.
    clear.
  Admitted.

  Lemma horcomp_pre_post :
    Π (C D:precategory) ( E : Precategory) (F F' : functor C D) (G G' : functor D E) (f:F ⟶ F') (g:G ⟶ G'),
    horcomp f g = compose (C:=functor_Precategory C E) (a:= (G □ F)) (b:= (G' □ F)) (c:= (G' □ F'))
                          (pre_whisker F g)
                          (post_whisker f G').
  Proof.
    intros.
    apply nat_trans_eq.
    apply homset_property.
    intros;
    apply idpath.
  Qed.    


  Lemma isEpi_horcomp (B :precategory)(C D:Precategory)
        (G H : functor B C) (G' H' : functor C D)
        (f:nat_trans G H) (f':nat_trans G' H')
    : isEpi (C:= functor_Precategory _ _) f
      -> (Π x, isEpi  (f' x))
      -> isEpi (C:=functor_Precategory B D)
              (x:= (G' □ G)) (y:= (H' □ H))
              (horcomp f f').
  Proof.
    intros epif epif'.
    rewrite horcomp_pre_post.
    apply isEpi_comp.
    -now apply isEpi_pre_whisker.
    -now apply isEpi_post_whisker.
  Qed.


(*
A morphism of arity F : a -> b induces a functor between representation Rep(b) -> Rep(a)

In this section we construct the left adjoint of this functor (which is defined whenever
F is an epimorphism)
 *)
Section leftadjoint.


  Local Notation C := hset_Precategory.
  Local Notation SET := hset_Precategory.
  Local Notation PARITY := (arity_Precategory C).
  Local Notation BREP := (brep_disp C).

  Variables (a b:PARITY) (R:BREP a)
            (F:PARITY ⟦ a, b⟧).

  Local Notation "## F" := (pr1 (pr1 (F)))(at level 3).

  Definition equivc   {c:ob C} (x y:pr1 ( ## R c)) :=
                                  (Π (S:BREP b) ( f : R -->[F] S),
                                   pr1 (pr1 f) c x = ## f c y).


  Lemma isaprop_equivc_xy (c:ob C) x y : isaprop (equivc (c:=c) x y).
    intros.
    apply impred_isaprop.
    intros S.
    apply impred_isaprop.
    intros f.
    apply setproperty.
  Qed.

  Definition equivc_xy_prop (c:ob C) x y : hProp :=
    (equivc  (c:=c) x y ,, isaprop_equivc_xy c x y).

  Definition hrel_equivc c : hrel _ := fun x y => equivc_xy_prop c x y.

  Lemma iseqrel_equivc c : iseqrel (hrel_equivc c).
    unfold hrel_equivc, equivc_xy_prop, equivc; simpl;
      repeat split.
    -  intros x y z. cbn.
       intros h1 h2 S f.
       now rewrite h1,h2.
    - intros x y; cbn.
      intros h S f.
      now symmetry.
  Qed.


  Definition eqrel_equivc c : eqrel _ := (_ ,, iseqrel_equivc c).

  Lemma congr_equivc: Π (x y:C) (f:C⟦ x,  y⟧), iscomprelrelfun (eqrel_equivc x) (eqrel_equivc y) (# (## R) f).
    intros.
    red.
    intros z z' eqz.
    intros S g.
    cbn in eqz.
    unfold equivc in eqz.

    assert (hg := nat_trans_ax (pr1 (pr1 g)) x y f).

    apply toforallpaths in hg.
    etrans.
    apply hg.
    symmetry; etrans. apply hg.
    cbn.
    now rewrite eqz.
  Qed.

  (* copié de ssreflect. Voir plus loin pour l'utilisation *)
  Lemma master_key : unit.
    exact tt.
  Qed.
  Definition locked {A} := unit_rect _  (fun x : A => x) master_key.
  
  Lemma lock A x : x = locked x :> A.
  Proof.
    unfold locked.
    now destruct master_key.
  Qed.    

  
  (* Foncteur candidat 

I need to make it not convertible to quot_functor otherwise
Coq takes a long time to check or compute things.
For example :   R' ((R' □ R') c) = (R' □ R') (R' c) by reflexivity
is so slow when R' is definitely equal to quot_functor !

*)
  Definition R' := ( quot_functor (pr1 (pr1 R)) _ congr_equivc).
  (* Opaque R'. *)

(*
  Lemma bizarre c: (* forall (R':functor SET SET),  *)  R' ((R' □ R') c) = (R' □ R') (R' c).
    (* intros ?. *)

    reflexivity.
  Qed.
*)
    (* cbn - [R']. *)
    (* reflexivity. *)
    (* !! amazing 
Qed takes so long !!!
*)
  (* Admitted.  *)

  Definition projR : (## R) ⟶ R':= proj_quot _ _ congr_equivc.

  (* Definition projR_lock : (## R) ⟶ R':= proj_quot _ _ congr_equivc. *)

  Arguments projR : simpl never.
  Arguments R' : simpl never.

(* TODO : déplacer dans quotient vector.v *)
  Lemma eq_proj_quot_rel X x y : projR X x = projR X y ->equivc x y.
  Proof.
    apply invmap.
    apply (weqpathsinsetquot (eqrel_equivc X)).
  Qed.
  Lemma rel_eq_proj_quot X x y : equivc x y ->projR X x = projR X y.
  Proof.
    apply (weqpathsinsetquot (eqrel_equivc X)).
  Qed.

  

  (* R' est un pseudo objet initial au sens suivant :
     Quel que soit        g : R ---> S morphisme dans la catégorie des représentations de a
     il existe un unique  u : R'---> S tel que g = u o projR
C'est un pseudo objet car il reste à montrer que R' est bien dans la catégorie des représentations
de a et que u est un morphisme de modules.
   *)
  Section CandidatU.
    Context {S:BREP b} (m:R -->[ F] S).

    Definition u : nat_trans (pr1 R') (## S).
      apply (univ_surj_nt projR (## m)); [| apply is_epi_proj_quot].
      abstract(
      intros X x y eqpr;
      apply eq_proj_quot_rel in eqpr;
      apply eqpr).
    Defined.

    Lemma u_commutes : ## m = projR ;;; u.
    Proof.
      symmetry.
      apply univ_surj_nt_ax.
    Qed.

  End CandidatU.


  Definition R'_η : (functor_identity C) ⟶ R' := η (## R) ;;; projR .

  Lemma R'_η_def : Π x, R'_η x =  η (## R) x ;; projR x.
  Proof.
    intro x.
    apply idpath.
  Qed.

  
  Notation GODMENT a b := (horcomp a b) (only parsing).


  Lemma comp_cat_comp {A B C:hSet} (f : A -> B) (g:B -> C) x :
    g (f x) = compose (C:= SET) f g x.
  Proof.
    reflexivity.
  Qed.




  
  (* R'_μ is defined by the following diagram :

                  μ R
            R R  ----->   R
             |           |
 projR projR |     H     | projR
             v           v
            R' R' ---->  R'
                  R'_μ

   *)
  Lemma compat_μ_projR : Π (X : SET) (x y : pr1 ((pr1 (## R □ ## R)) X)),
                            GODMENT projR projR X x = GODMENT projR projR X y →
                            (μ ## R;;; projR) X x = (μ ## R;;; projR) X y.
  Proof.
    intros X x y.
    intros hxy.
    apply rel_eq_proj_quot.
    intros S f.
    rewrite comp_cat_comp.
    match goal with |- ?f0 x = ?t => set (z:=f0); change t with (z y) end.
    neweqsubst z.
    etrans.
    apply Monad_Mor_μ.
    match goal with |- nat_trans_data ?z' _ ;;_ ;; _ = _ => set (z := z') end.
    neweqsubst z.      
    apply u_commutes.
    etrans.
    apply cancel_postcomposition.
    etrans.
    symmetry.      
    apply  (assoc (C:=SET) (projR (## R X)) (u f (## R X))).
    apply cancel_precomposition.
    etrans.
    
    symmetry.
    apply nat_trans_ax.

    apply cancel_postcomposition.
    apply (functor_comp _ _ _ _ (projR X) (u f X)).
    repeat rewrite assoc.
    reflexivity.
    cbn.
    apply maponpaths.
    apply maponpaths.
    apply maponpaths.
    apply toolong.
    (* exact hxy. *)
  Qed.
  
  Definition R'_μ  : nat_trans ( R'□  R')  ( R').
  Proof.
    apply (univ_surj_nt (A:= ##R □ ##R) (B:=functor_composite R' R')                    
                       (horcomp projR projR)
                       (μ  (## R) ;;; projR)).
    (* asbtract these *)
    -  apply compat_μ_projR.
      
    - abstract(apply isEpi_horcomp;
               [|apply is_pointwise_epi_from_set_nat_trans_epi];
      apply is_epi_proj_quot).
  Defined.

  Lemma R'_μ_def : Π (x:SET),
                     horcomp projR projR x ;; R'_μ x = μ (## R) x ;; projR x .
  Proof.
    intro x.
    unfold R'_μ.
    apply univ_surj_nt_ax_pw.
  Qed.

  Definition R'_Monad_data : Monad_data C := ((R' ,, R'_μ) ,, R'_η).
  (*
  Goal Π c, identity (R'_Monad_data c) = identity (R'_Monad_data c).
    intro c.
    unfold R'_Monad_data.
    simpl.
    cbn.
   *)
  Lemma cancel_functor_on_morph :
    Π (C C' : precategory_ob_mor)
      (F : functor_data C C') (a b : C) (m m': C ⟦ a, b ⟧) ,
    m = m' -> #F m = #F m'.
  Proof.
    intros ??????? e.
    now destruct e.
  Qed.

  
  Lemma R'_Monad_laws : Monad_laws R'_Monad_data.
  Proof.
    repeat split.
    -       cbn -[R' compose identity].
      intro c.
      use (is_pointwise_epi_from_set_nat_trans_epi _ _ _ (projR)).
      apply is_epi_proj_quot.

      repeat rewrite assoc.
      etrans.
      apply (cancel_postcomposition (b:=R' (R' c))).
      apply (cancel_postcomposition _ ((η ## R) (## R c) ;; # (## R) (projR _))).
      apply (nat_trans_ax (η ## R)).

      rewrite <- assoc.
      rewrite <- assoc.
      etrans.
      apply (cancel_precomposition _ _ _ (R' c)).
      apply R'_μ_def.
      
      rewrite assoc, id_right.
      etrans.
      apply cancel_postcomposition.
      apply (Monad_law1 (T:=pr1 R)).
      apply id_left.
      
    - intro c.
      etrans.
      apply cancel_postcomposition.
      etrans.
      apply cancel_functor_on_morph.
      apply R'_η_def.
      apply functor_comp.
      use (is_pointwise_epi_from_set_nat_trans_epi _ _ _ projR).
      apply is_epi_proj_quot.
      repeat rewrite assoc.
      etrans.
      (apply cancel_postcomposition).
      apply cancel_postcomposition.
      symmetry.
      apply (nat_trans_ax (projR)).
      rewrite <- assoc.
      rewrite <- assoc.
      etrans.
      apply cancel_precomposition.
      apply R'_μ_def.
      rewrite assoc, id_right.
      rewrite (Monad_law2 (T:=pr1 R)).
      now rewrite id_left.
    - intro c.             
      cbn -[R' compose].
      (* Note : 

If I write instead :
  assert (epi :isEpi (horcomp projR (horcomp projR projR)  c)).
(convertibly the same by associativity)

then 'apply epi' takes a huge amount of time for Coq !!
This is due to the fact that Coq takes a long time to show that
   ((R' □ R') □ R') c = R' ((R' □ R') c)
because it has a very bad computing strategy. He tries to evaluates R'
which is bad idea. Probably because somewhere there is a Defined instead of 
Qed for some proof, and I suspect somewhere in the section about
quotients in basics/Sets.v

       *)
      assert (epi :isEpi (horcomp (horcomp projR projR) projR c)).
      {
        apply Colims_pw_epi.
        apply PushoutsHSET.        
        apply isEpi_horcomp;[   apply isEpi_horcomp|]; try apply Colims_pw_epi;
          try apply PushoutsHSET; apply is_epi_proj_quot.
      }
      apply epi.

      (* To understand the proof, see the string diagram muproof sent to
Benedikt.

Legend of the diagram :
- μ = μ R
- ν = R'_μ
- i = projR
*)      
      etrans.

      (* First equality *)
      etrans.

      apply assoc.

      rewrite horcomp_pre_post.
      
      etrans.
      apply (cancel_postcomposition (C:=SET)).
      
      etrans.
      apply (cancel_postcomposition (C:=SET)).
      unfold compose.
      cbn -[R' compose horcomp].
      reflexivity.

      etrans.
      rewrite <- assoc.      
      apply (cancel_precomposition SET).
      rewrite <- (functor_comp (C:=SET) (C':=SET)).
      apply cancel_functor_on_morph.
      apply R'_μ_def.
      
      rewrite functor_comp,assoc.
      apply cancel_postcomposition.
      symmetry.
      apply (nat_trans_ax (projR)).

      (* second equality *)
      rewrite <- assoc.
      rewrite <- assoc.
      apply (cancel_precomposition (SET)).     
      apply (R'_μ_def c).

      (* third equality *)
      etrans.
      rewrite assoc.
      
      etrans.
      apply cancel_postcomposition.
      apply (Monad_law3 (T:=pr1 R) c).

      (* Fourth equality *)
      rewrite <- assoc.
      
      etrans.
      apply cancel_precomposition.
      symmetry.
      apply R'_μ_def.

      rewrite assoc.      
      apply cancel_postcomposition.

      (* Fifth equality *)
      etrans.
      cbn -[projR compose].
      rewrite (assoc (C:=SET)).
      apply (cancel_postcomposition (C:=SET)).
      symmetry.
      apply R'_μ_def.


      (* Close to the end *)
      etrans.
      rewrite <- assoc.
      apply (cancel_precomposition SET).
      symmetry.
      apply (nat_trans_ax (R'_μ) (## R c)).
      
      rewrite assoc.
      reflexivity.

      etrans.
      rewrite <- assoc.
      reflexivity.

      (* So mMmMmuuchhh tiime *)
      apply cancel_postcomposition.

      TODO

End leftadjoint.

Section representable.


  Local Notation C := hset_Precategory.
  Local Notation PARITY := (arity_Precategory C).
  Local Notation BREP := (brep_disp C).

  Local Notation initial_rep_type a :=   (Initial (fiber_precategory BREP a)).


  (* an arity is representable if there is an initial object in the category
of representations of the arity*)
  Definition is_representable (a:PARITY) := initial_rep_type a.

  Variables (a b:PARITY) (R:initial_rep_type a)
    (F:Epi _ a b).


  (* Now we are to prove that b is representable *)

  (* We define the quotient of R *)
  Definition R'_data c := Quot F (pr1 R) c.