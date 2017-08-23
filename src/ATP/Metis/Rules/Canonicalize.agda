------------------------------------------------------------------------------
-- Agda-Metis Library.
-- Canonicalize inference rule.
------------------------------------------------------------------------------

open import Data.Nat using ( ℕ; suc; zero )

module ATP.Metis.Rules.Canonicalize ( n : ℕ ) where

------------------------------------------------------------------------------

open import ATP.Metis.Rules.Reordering n
  using ( right-assoc-∨; reorder-∧∨; thm-reorder-∧∨; reorder-∨ )

open import Data.Bool.Base
  using    ( true; false )
  renaming ( _∨_ to _or_ )

open import Data.Prop.Dec n                  using ( ⌊_⌋ ; yes ; no )
open import Data.Prop.Properties n           using ( eq ; subst )
open import Data.Prop.Syntax n
open import Data.Prop.Theorems n
open import Data.Prop.NormalForms n
open import Data.Prop.Views n

open import Data.Prop.SyntaxExperiment n    using ( right-assoc-∧ )

open import Data.Bool using (Bool; true; false) renaming (_∨_ to _or_ )

open import Function                         using ( _$_; id ; _∘_ )
open import Relation.Binary.PropositionalEquality
  using ( _≡_; refl; sym ; trans)

------------------------------------------------------------------------------


-- All formulas are in NNF.

data canonView : Prop  → Set where

-- Conjunction simplification cases.
  sconj₁ : (φ₁ : Prop)    → canonView (φ₁ ∧ ⊤)     -- φ ∧ ⊤ ==> φ.
  sconj₂ : (φ₁ : Prop)    → canonView (⊤ ∧ φ₁)     -- ⊤ ∧ φ ==> φ.
  sconj₃ : (φ₁ : Prop)    → canonView (φ₁ ∧ ⊥)     -- φ ∧ ⊥ ==> ⊥.
  sconj₄ : (φ₁ : Prop)    → canonView (⊥ ∧ φ₁)     -- ⊥ ∧ φ ==> ⊥.
  sconj₅ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∧ φ₂)    -- φ ∧ φ ==> φ.
  sconj₆ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∧ φ₂)    -- φ ∧ ¬ φ ==> ⊥.
  sconj₇ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∧ φ₂)    -- ¬ φ ∧ φ ==> ⊥.
  sconj₈ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∧ φ₂)

-- Disjunction simplification cases.
  sdisj₁ : (φ₁ : Prop)    → canonView (φ₁ ∨ ⊤)     -- φ ∨ ⊤ ==> ⊤.
  sdisj₂ : (φ₁ : Prop)    → canonView (⊤ ∨ φ₁)     -- ⊤ ∨ φ ==> ⊤.
  sdisj₃ : (φ₁ : Prop)    → canonView (φ₁ ∨ ⊥)     -- φ ∨ ⊥ ==> φ.
  sdisj₄ : (φ₁ : Prop)    → canonView (⊥ ∨ φ₁)     -- ⊥ ∨ φ ==> φ.
  sdisj₅ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∨ φ₂)    -- φ ∨ φ ==> φ.
  sdisj₆ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∨ φ₂)    -- φ ∨ ¬ φ ==> ⊤.
  sdisj₇ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∨ φ₂)    -- ¬ φ ∨ φ ==> ⊤.
  sdisj₈ : (φ₁ φ₂ : Prop) → canonView (φ₁ ∨ φ₂)

  ntop   : canonView (¬ ⊤)                         -- ¬ ⊤ ==> ⊥
  nbot   : canonView (¬ ⊥)                         -- ¬ ⊥ ==> ⊤
  other  : (φ₁ : Prop)    → canonView φ₁


canon-view : (φ : Prop) → canonView φ
canon-view (φ ∧ ⊤) = sconj₁ _
canon-view (⊤ ∧ φ) = sconj₂ _
canon-view (φ ∧ ⊥) = sconj₃ _
canon-view (⊥ ∧ φ) = sconj₄ _
canon-view (φ ∧ φ₁)
  with ⌊ eq φ φ₁ ⌋ | ⌊ eq φ (¬ φ₁) ⌋ | ⌊ eq (¬ φ) φ₁ ⌋
...  | true  | _     | _    = sconj₅ _ _
...  | _     | true  | _    = sconj₆ _ _
...  | _     | _     | true = sconj₇ _ _
...  | _     | _     | _    = sconj₈ _ _

canon-view (φ ∨ ⊤) = sdisj₁ _
canon-view (⊤ ∨ φ) = sdisj₂ _
canon-view (φ ∨ ⊥) = sdisj₃ _
canon-view (⊥ ∨ φ) = sdisj₄ _
canon-view (φ ∨ φ₁)
  with ⌊ eq φ φ₁ ⌋ | ⌊ eq φ (¬ φ₁) ⌋ | ⌊ eq (¬ φ) φ₁ ⌋
...  | true  | _     | _    = sdisj₅ _ _
...  | _     | true  | _    = sdisj₆ _ _
...  | _     | _     | true = sdisj₇ _ _
...  | _     | _     | _    = sdisj₈ _ _

canon-view (¬ ⊤) = ntop
canon-view (¬ ⊥) = nbot
canon-view  φ    = other _

canon : Prop → Prop
canon φ with canon-view φ
... | sconj₁ φ₁    = φ₁
... | sconj₂ φ₁    = φ₁
... | sconj₃ _     = ⊥
... | sconj₄ _     = ⊥
... | sconj₅ φ₁ _  = φ₁
... | sconj₆ φ₁ φ₂ = ⊥
... | sconj₇ φ₁ φ₂ = ⊥
... | sconj₈ φ₁ φ₂ = φ₁ ∧ φ₂

... | sdisj₁ φ₁    = ⊤
... | sdisj₂ φ₁    = ⊤
... | sdisj₃ φ₁    = φ₁
... | sdisj₄ φ₁    = φ₁
... | sdisj₅ φ₁ φ₂ = φ₁
... | sdisj₆ φ₁ φ₂ = ⊤
... | sdisj₇ φ₁ φ₂ = ⊤
... | sdisj₈ φ₁ φ₂ = φ₁ ∨ φ₂

... | ntop         = ⊤
... | nbot         = ⊤
... | other .φ     = φ


-- canon : ℕ → Prop → Prop
-- canon zero φ    = φ
-- canon (suc n) φ with canon-view φ
-- ... | sconj₁ φ₁    = canon n φ₁
-- ... | sconj₂ φ₁    = canon n φ₁
-- ... | sconj₃ _     = ⊥
-- ... | sconj₄ _     = ⊥
-- ... | sconj₅ φ₁ _  = canon n φ₁
-- ... | sconj₆ φ₁ φ₂ = ⊥
-- ... | sconj₇ φ₁ φ₂ = ⊥
-- ... | sconj₈ φ₁ φ₂ = canon (canon n φ₁ ∧ canon n φ₂)

-- ... | sdisj₁ φ₁    = canon n φ₁
-- ... | sdisj₂ φ₁    = canon n φ₁
-- ... | sdisj₃ φ₁    = canon n φ₁
-- ... | sdisj₄ φ₁    = canon n φ₁
-- ... | sdisj₅ φ₁ φ₂ = canon n φ₁
-- ... | sdisj₆ φ₁ φ₂ = ⊤
-- ... | sdisj₇ φ₁ φ₂ = ⊤
-- ... | sdisj₈ φ₁ φ₂ = canon (canon n φ₁ ∨ canon n φ₂)

-- ... | nconj φ₁ φ₂  = φ₂
-- ... | ndisj φ₁ φ₂  = φ₂
-- ... | nneg φ₁      = canon n φ₁
-- ... | ntop         = ⊤
-- ... | nbot         = ⊤
-- ... | other .φ     = φ

-- snnf : Prop → Prop
-- snnf φ = (canon (ubsizetree (nnf φ)) (nnf φ))

-- canonicalize_to_ : Prop → Prop →  Prop
-- canonicalize φ to φ₁
--   with ⌊ eq φ₁ (snnf φ) ⌋
-- ...  | true  = snnf φ
-- ...  | false with ⌊ eq φ₁ (dist′ (snnf φ)) ⌋
-- ...          | true = dist′ (snnf φ)
-- ...          | false  with ⌊ eq φ₁ (dist (snnf φ)) ⌋
-- ...                      | true = dnf (dist φ)
-- ...                      | false = φ₁

_∈-∨_ : Prop → Prop → Bool
φ ∈-∨ ψ
  with ⌊ eq φ ψ ⌋
...  | true = true
...  | false
     with disj-view ψ
...     | other .ψ   = false
...     | disj ψ₁ ψ₂ = φ ∈-∨ ψ₁ or φ ∈-∨ ψ₂

-- We assumed here that the formula is a disjunction and its right-associated.
rmDuplicates-∨ : Prop → Prop
rmDuplicates-∨ φ
  with disj-view φ
... | other _  = φ
... | disj φ₁ φ₂
    with φ₁ ∈-∨ φ₂
...    | true  = rmDuplicates-∨ φ₂
...    | false = φ₁ ∨ rmDuplicates-∨ φ₂

_∈-∧_ : Prop → Prop → Bool
φ ∈-∧ ψ
  with ⌊ eq (reorder-∨ φ ψ) ψ ⌋
...  | true = true
...  | false
     with conj-view ψ
...     | other .ψ   = false
...     | conj ψ₁ ψ₂ = φ ∈-∧ ψ₁ or φ ∈-∧ ψ₂


-- We assumed here that the formula is a disjunction and its right-associated.
rmDuplicates-∧∨ : Prop → Prop
rmDuplicates-∧∨ φ
  with conj-view φ
...  | other _    = rmDuplicates-∨ (right-assoc-∨ φ)
...  | conj φ₁ φ₂ = rmDuplicates-∧∨ φ₁ ∧ rmDuplicates-∧∨ φ₂

rmDuplicates-∧ : Prop → Prop
rmDuplicates-∧ φ
  with conj-view φ
...  | other _  = φ
...  | conj φ₁ φ₂
     with φ₁ ∈-∧ φ₂
...     | true  = rmDuplicates-∧ φ₂
...     | false = φ₁ ∧ rmDuplicates-∧ φ₂

rmDuplicatesCNF : Prop → Prop
rmDuplicatesCNF φ =
  rmDuplicates-∧ (rmDuplicates-∧∨ (right-assoc-∧ (cnf φ)))

thm-rmDuplicatesCNF
  : ∀ {Γ} {φ}
  → Γ ⊢ φ
  → Γ ⊢ reorder-∧∨ φ (rmDuplicatesCNF φ)
thm-rmDuplicatesCNF {Γ}{φ} Γ⊢φ =
  thm-reorder-∧∨ Γ⊢φ (rmDuplicatesCNF φ)

-- Remove φ ∨ ¬ φ pairs.


-- φ ∨ ¬ φ deletions in a right-associated formula.

rmPairs-∨ : Prop → Prop
rmPairs-∨ φ
  with disj-view φ
... | other .φ   = φ
... | disj φ₁ φ₂
    with neg-view φ₁
rmPairs-∨ .(¬ φ ∨ φ₂) | disj .(¬ φ) φ₂ | neg φ
    with φ ∈-∨ φ₂
rmPairs-∨ .(¬ φ ∨ φ₂) | disj .(¬ φ) φ₂ | neg φ | true  = ⊤
rmPairs-∨ .(¬ φ ∨ φ₂) | disj .(¬ φ) φ₂ | neg φ | false
   with ⌊ eq (rmPairs-∨ φ₂) ⊤ ⌋
rmPairs-∨ .(¬ φ ∨ φ₂) | disj .(¬ φ) φ₂ | neg φ | false | false = ¬ φ ∨ rmPairs-∨ φ₂
rmPairs-∨ .(¬ φ ∨ φ₂) | disj .(¬ φ) φ₂ | neg φ | false | true  = ⊤
rmPairs-∨ .(φ₁ ∨ φ₂)  | disj φ₁ φ₂     | pos .φ₁
    with (¬ φ₁) ∈-∨ φ₂
rmPairs-∨ .(φ₁ ∨ φ₂) | disj φ₁ φ₂ | pos .φ₁ | true  = ⊤
rmPairs-∨ .(φ₁ ∨ φ₂) | disj φ₁ φ₂ | pos .φ₁ | false
  with ⌊ eq (rmPairs-∨ φ₂) ⊤ ⌋
rmPairs-∨ .(φ₁ ∨ φ₂) | disj φ₁ φ₂ | pos .φ₁ | false | false = φ₁ ∨ rmPairs-∨ φ₂
rmPairs-∨ .(φ₁ ∨ φ₂) | disj φ₁ φ₂ | pos .φ₁ | false | true  = ⊤


-- We assumed here that the formula is a disjunction and its right-associated.
clean-∧∨ : Prop → Prop
clean-∧∨ φ
  with conj-view φ
...  | other _    = rmPairs-∨ φ
...  | conj φ₁ φ₂
     with ⌊ eq (clean-∧∨ φ₁) ⊤ ⌋
...  | true  = clean-∧∨ φ₂
...  | false
     with  ⌊ eq (clean-∧∨ φ₁) ⊥ ⌋
...     |  true = ⊥
...     |  false
        with ⌊ eq (clean-∧∨ φ₂) ⊤ ⌋
...        | true  = clean-∧∨ φ₁
...        | false
           with  ⌊ eq (clean-∧∨ φ₂) ⊥ ⌋
...           |  true = ⊥
...           |  false = (clean-∧∨ φ₁) ∧ (clean-∧∨ φ₂)


--∧ clean-∧∨ φ₂

clean : Prop → Prop
clean φ = clean-∧∨ (rmDuplicatesCNF φ)

------------------------------------------------------------------------------
-- atp-canonicalize.
------------------------------------------------------------------------------

postulate
  atp-canonicalize
    : ∀ {Γ} {φ}
    → (φ′ : Prop)
    → Γ ⊢ φ
    → Γ ⊢ φ′
