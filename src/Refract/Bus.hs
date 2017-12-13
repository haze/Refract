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


events bus = do
    z <- bus
    (Bus _ fs) <- M.readMVar z
    return fs

createBlankBus :: Event e => e -> IO ( M.MVar (Bus e f) )
createBlankBus ev = M.newMVar $ Bus ev []

operate :: Event a => ([a -> IO ()] -> [a -> IO ()]) -> IO (M.MVar (Bus a f)) -> IO ()
operate fn bus = bus >>= \z -> M.modifyMVar_ z (\(Bus ev fs) -> return $ Bus ev $ fn fs)

associate :: Event a => (a -> IO ()) -> IO (M.MVar (Bus a f)) -> IO ()
associate func = operate (func :)

dissociate :: (Event a, Eq (a -> IO ())) => (a -> IO ()) -> IO (M.MVar (Bus a f)) -> IO ()
dissociate func = operate (filter (/= func))

fire :: (Event a) => a -> IO (M.MVar (Bus a f)) -> IO ()
fire ev _bus = do
    z <- _bus
    bus <- M.readMVar z
    let (Bus _ fs) = bus
    for_ fs ($ ev)