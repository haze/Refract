module Main where

import qualified Control.Concurrent.MVar as M
import qualified Refract.Bus as R
import           Refract.Event
import           System.Exit             (exitFailure, exitSuccess)


smallerThanSix :: MessageEvent -> Bool
smallerThanSix (MessageEvent msg) = length msg < 6

newtype MessageEvent = MessageEvent String
instance Event MessageEvent where
    filters _ = [ \(MessageEvent msg) -> length msg > 2, smallerThanSix ]
    base = MessageEvent ""

showMessage :: MessageEvent -> IO ()
showMessage (MessageEvent msg) = putStrLn msg

main :: IO ()
main = do
    bus <- R.createBlankBus (base :: MessageEvent)
    R.associate' showMessage bus
    R.fire bus (MessageEvent "12")
    R.fire bus (MessageEvent "1234")
    R.fire bus (MessageEvent "124567")
