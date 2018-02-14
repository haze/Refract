module Main where

import qualified Control.Concurrent.MVar as M
import           Refract.Bus
import           Refract.Event
import           System.Exit             (exitFailure, exitSuccess)

newtype MessageEvent = MessageEvent String
instance Filter MessageEvent where
instance Event MessageEvent where

showMessage :: MessageEvent -> IO ()
showMessage (MessageEvent msg) = putStrLn msg

showMessage' :: MessageEvent -> IO ()
showMessage' (MessageEvent msg) = putStrLn $ "second: " ++ msg

main :: IO ()
main = do
    bus <- createBlankBus (MessageEvent "test")
    associate' showMessage bus
    associate' showMessage' bus
    fire bus (MessageEvent "test, 1.")
    fire bus (MessageEvent "test, 2.")
    fire bus (MessageEvent "test, 3.")
