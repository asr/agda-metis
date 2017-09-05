------------------------------------------------------------------------------
-- Agda-Metis Library.
------------------------------------------------------------------------------

open import Data.Nat using ( ℕ )

module ATP.Metis ( n : ℕ ) where

------------------------------------------------------------------------------

open import Data.PropFormula.Syntax n

open import ATP.Metis.Rules n public

------------------------------------------------------------------------------

$false : PropFormula
$false = ⊥
