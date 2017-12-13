{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs             #-}

module Refract.Bus
    ( createBlankBus
    , associate
    , associate'
    , dissociate
    , fire
    , Bus(..) ) where

import qualified Control.Concurrent.MVar as M
import           Control.Monad
import           Data.Foldable           (for_)
import           Refract.Event
import Data.List (sortBy)

data PrioritizedFunction e = PrioritizedFunction Int ( e -> IO () )
data Bus a f where Bus :: Event e => e -> [ PrioritizedFunction e ] -> Bus e f

priorityFunc :: PrioritizedFunction e -> e -> IO ()
priorityFunc (PrioritizedFunction _ fn) = fn

instance (Show e, Event e) => Show (Bus e [e -> IO () ]) where
    show (Bus ev f) = "Bus<" ++ show ev ++ "> [" ++ show (length f) ++ "]"

createBlankBus :: Event e => e -> IO ( M.MVar (Bus e f) )
createBlankBus ev = M.newMVar $ Bus ev []

pCompare :: (Event e) => PrioritizedFunction e -> PrioritizedFunction e -> Ordering
pCompare (PrioritizedFunction a _) (PrioritizedFunction b _) = compare a b

operate :: ([PrioritizedFunction a] -> [PrioritizedFunction a]) -> M.MVar (Bus a f) -> IO ()
operate fn bus = M.modifyMVar_ bus (\(Bus ev fs) -> return $ Bus ev $ fn fs)

associate :: Int -> (a -> IO ()) -> M.MVar (Bus a f) -> IO ()
associate priority func = operate (PrioritizedFunction priority func :)

associate' :: (a -> IO ()) -> M.MVar (Bus a f) -> IO ()
associate' = associate 1

dissociate :: Eq (PrioritizedFunction a) => PrioritizedFunction a -> M.MVar (Bus a f) -> IO ()
dissociate func = operate (filter (/= func))

combineFilters :: [a -> Bool] -> (a -> Bool)
combineFilters = foldr (liftM2 (&&)) $ const True

fire :: (Event a) => a -> M.MVar (Bus a f) -> IO ()
fire ev bus = when (combined ev) $ M.readMVar bus >>= runAll
    where runAll (Bus _ fs) = for_ (sortBy pCompare $ reverse fs) (`priorityFunc` ev)
          combined = combineFilters $ filters ev
