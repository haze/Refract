module Main where

import qualified Control.Concurrent.MVar as M
import System.Exit (exitSuccess, exitFailure)
import Refract.Event
import Refract.Bus

newtype MessageEvent = MessageEvent String
instance Filter MessageEvent where
instance Event MessageEvent where

base :: MessageEvent
base = MessageEvent ""

showMessage :: MessageEvent -> IO ()
showMessage (MessageEvent msg) = putStrLn msg

main :: IO ()
main = do
    bus <- createBlankBus (base :: MessageEvent)
    (Bus _ before) <- M.readMVar bus
    associate showMessage bus
    (Bus _ after) <- M.readMVar bus
    if length before == length after then exitFailure else exitSuccess