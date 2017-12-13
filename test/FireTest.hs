module Main where

import qualified Control.Concurrent.MVar as M
import           Refract.Bus
import           Refract.Event
import           System.Exit             (exitFailure, exitSuccess)

newtype IntEvent = IntEvent Int
instance Event IntEvent where
    base = IntEvent 0

showMessage :: IntEvent -> IO ()
showMessage (IntEvent msg) = print msg

showMessage' :: IntEvent -> IO ()
showMessage' (IntEvent msg) = putStrLn $ "second: " ++ show msg

main :: IO ()
main = do
    bus <- createBlankBus (base :: IntEvent)
    associate' showMessage bus
    associate' showMessage' bus
    fire (IntEvent 1) bus
    fire (IntEvent 2) bus
    fire (IntEvent 3) bus
