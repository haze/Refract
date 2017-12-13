{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs             #-}
module Refract.Bus where

import qualified Control.Concurrent.MVar as M
import           Data.Foldable           (for_)
import           Refract.Event

data Bus a f where Bus :: Event e => e -> [ e -> IO () ] -> Bus e f

instance (Show e, Event e) => Show (Bus e [e -> IO () ]) where
    show (Bus ev f) = "Bus<" ++ show ev ++ "> [" ++ show (length f) ++ "]"

createBlankBus :: Event e => e -> IO ( M.MVar (Bus e f) )
createBlankBus ev = M.newMVar $ Bus ev []

operate :: Event a => ([a -> IO ()] -> [a -> IO ()]) -> M.MVar (Bus a f) -> IO ()
operate fn bus = M.modifyMVar_ bus (\(Bus ev fs) -> return $ Bus ev $ fn fs)

associate :: Event a => (a -> IO ()) -> M.MVar (Bus a f) -> IO ()
associate func = operate (func :)

dissociate :: (Event a, Eq (a -> IO ())) => (a -> IO ()) -> M.MVar (Bus a f) -> IO ()
dissociate func = operate (filter (/= func))

fire :: (Event a) => a -> M.MVar (Bus a f) -> IO ()
fire ev bus = M.readMVar bus >>= runAll
    where runAll (Bus _ fs) = for_ (reverse fs) ($ ev)
